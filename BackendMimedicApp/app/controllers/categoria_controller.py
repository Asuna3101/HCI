from fastapi import HTTPException, status
from app.factories.service_factory import ServiceFactory


class CategoriaController:
    def __init__(self, db):
        cat_repo = ServiceFactory.create_categoria_repository(db)
        self.service = ServiceFactory.create_categoria_service(cat_repo)

    def listar_todas(self, skip: int = 0, limit: int = 100):
        try:
            return self.service.listar_todas(skip=skip, limit=limit)
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def obtener_por_id(self, id: int):
        try:
            cat = self.service.obtener_por_id(id)
            if not cat:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Categoria no encontrada")
            return cat
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def crear(self, nombre: str):
        try:
            return self.service.crear(nombre)
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def actualizar(self, id: int, nombre: str):
        try:
            cat = self.service.actualizar(id, nombre)
            if not cat:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Categoria no encontrada")
            return cat
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))

    def eliminar(self, id: int):
        try:
            ok = self.service.eliminar(id)
            if not ok:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Categoria no encontrada")
            return {"deleted": True}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
