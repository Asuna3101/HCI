from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory

class UnidadController:
    def __init__(self, db: Session):
        unidad_repo = ServiceFactory.create_unidad_repository(db)
        self.service = ServiceFactory.create_unidad_service(unidad_repo)

    def listar_todas(self):
        try:
            return self.service.listar_todas()
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al obtener unidades: {str(e)}"
            )
