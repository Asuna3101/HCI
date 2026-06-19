from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory


class ComidaController:
    def __init__(self, db: Session):
        comida_repo = ServiceFactory.create_comida_repository(db)
        self.service = ServiceFactory.create_comida_service(comida_repo)

    def listar_todas(self, skip: int = 0, limit: int = 100):
        try:
            return self.service.listar_todas(skip=skip, limit=limit)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al obtener alimentos: {str(e)}"
            )

    def buscar_por_nombre(self, query: str, limit: int = 20):
        """Busca comidas por nombre (autocompletado)"""
        try:
            return self.service.buscar_por_nombre(query, limit=limit)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al buscar comidas: {str(e)}"
            )

    def obtener_por_id(self, id: int):
        try:
            alm = self.service.obtener_por_id(id)
            if not alm:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alimento no encontrado")
            return alm
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def obtener_o_crear(self, nombre: str, detalles: str | None = None, recomendable: int = 1):
        try:
            return self.service.obtener_o_crear(nombre, detalles)
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def listar_por_recomendable(self, recomendable: int, skip: int = 0, limit: int = 100):
        try:
            # Deprecated for normalized schema: recomendable is per-user in comidas_usuario
            return self.service.listar_por_recomendable(recomendable, skip=skip, limit=limit)
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def crear(self, nombre: str, detalles: str | None = None):
        try:
            return self.service.crear(nombre, detalles)
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def actualizar(self, id: int, **kwargs):
        try:
            alm = self.service.actualizar(id, **kwargs)
            if not alm:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alimento no encontrado")
            return alm
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def eliminar(self, id: int):
        try:
            ok = self.service.eliminar(id)
            if not ok:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Alimento no encontrado")
            return {"deleted": True}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
