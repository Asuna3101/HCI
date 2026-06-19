from app.factories.service_factory import ServiceFactory
from sqlalchemy.orm import Session
from fastapi import HTTPException, status


class ComidaUsuarioController:
    def __init__(self, db: Session):
        self.db = db
        comida_repo = ServiceFactory.create_comida_repository(db)
        cu_repo = ServiceFactory.create_comida_usuario_repository(db)
        self.comida_service = ServiceFactory.create_comida_service(comida_repo)
        self.service = ServiceFactory.create_comida_usuario_service(cu_repo)

    def registrar(self, id_usuario: int, data):
        """Registra una comida para el usuario (crea en catálogo si no existe)"""
        try:
            # 1. Obtener o crear la comida en el catálogo
            nombre = data.nombre
            detalles = data.detalles if hasattr(data, 'detalles') else None
            
            comida = self.comida_service.obtener_o_crear(nombre, detalles)
            
            # 2. Crear asociación usuario-comida con categoría y descripción
            categoria_id = data.idCategoria if hasattr(data, 'idCategoria') else None
            descripcion = data.descripcion if hasattr(data, 'descripcion') else None
            
            return self.service.create_for_user(comida.id, id_usuario, categoria_id, descripcion)
        except ValueError as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al registrar comida: {str(e)}"
            )

    def listar(self, id_usuario: int):
        """Lista todas las comidas del usuario"""
        try:
            return self.service.list_for_user(id_usuario)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al obtener comidas del usuario: {str(e)}"
            )

    def actualizar(self, id: int, id_usuario: int, data):
        """Actualiza una comida del usuario"""
        try:
            # Verificar que la comida pertenezca al usuario
            comidas = self.service.list_for_user(id_usuario)
            if not any(c.id == id for c in comidas):
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Comida no encontrada o no pertenece al usuario"
                )
            
            update_data = {}
            
            # Si se cambió el nombre, buscar o crear en el catálogo
            if hasattr(data, 'nombre') and data.nombre is not None and data.nombre.strip():
                nueva_comida = self.comida_service.obtener_o_crear(data.nombre.strip(), None)
                update_data['comida_id'] = nueva_comida.id
            
            if hasattr(data, 'descripcion') and data.descripcion is not None:
                update_data['descripcion'] = data.descripcion
            if hasattr(data, 'idCategoria') and data.idCategoria is not None:
                update_data['categoria_id'] = data.idCategoria
            
            if not update_data:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="No hay datos para actualizar"
                )
            
            actualizado = self.service.update(id, update_data)
            if not actualizado:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="No se pudo actualizar la comida"
                )
            
            return actualizado
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al actualizar comida: {str(e)}"
            )

    def delete(self, id: int):
        try:
            ok = self.service.delete(id)
            if not ok:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Registro no encontrado")
            return {"deleted": True}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def eliminar(self, id_usuario: int, comida_ids: list[int]):
        """Elimina múltiples comidas del usuario"""
        try:
            ok = self.service.delete_multiple(comida_ids)
            if not ok:
                raise ValueError("No se pudieron eliminar las comidas")
            return {
                "success": True,
                "message": "Comidas eliminadas correctamente"
            }
        except ValueError as e:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al eliminar comidas: {str(e)}"
            )
