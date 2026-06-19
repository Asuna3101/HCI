from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory


class EjercicioUsuarioController:

    def __init__(self, db: Session):
        ejxuser_repo = ServiceFactory.create_ejercicio_usuario_repository(db)
        ejercicio_repo = ServiceFactory.create_ejercicio_repository(db)
        self.service = ServiceFactory.create_ejercicio_usuario_service(ejxuser_repo, ejercicio_repo)

    def registrar(self, id_usuario: int, data):
        try:
            return self.service.registrar_ejercicio_usuario(id_usuario, data)
        except ValueError as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al registrar ejercicio: {str(e)}"
            )

    def listar(self, id_usuario: int):
        try:
            return self.service.obtener_ejercicios_usuario(id_usuario)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al obtener ejercicios del usuario: {str(e)}"
            )

    def actualizar(self, ejercicio_id: int, data):
        try:
            result = self.service.actualizar_ejercicio_usuario(ejercicio_id, data)
            if not result:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ejercicio no encontrado")
            return result
        except ValueError as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al actualizar ejercicio: {str(e)}"
            )

    def eliminar(self, id_usuario: int, ejercicio_ids: list[int]):
        try:
            self.service.eliminar_ejercicios_usuario(id_usuario, ejercicio_ids)
            return {
                "success": True,
                "message": "Ejercicios eliminados correctamente"
            }
        except ValueError as e:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al eliminar ejercicios: {str(e)}"
            )