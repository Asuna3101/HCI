"""
Controlador para Tomás usando ServiceFactory (DIP)
"""
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory


class TomaController:
    def __init__(self, db: Session):
        toma_repo = ServiceFactory.create_toma_repository(db)
        self.service = ServiceFactory.create_toma_service(toma_repo)

    def marcar_toma(self, toma_id: int, tomado: bool):
        try:
            return self.service.marcar_toma(toma_id, tomado)
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(e),
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al actualizar toma: {str(e)}",
            )

    def postpone_tomas(self, toma_id: int, minutes: int):
        try:
            return self.service.postpone_tomas(toma_id, minutes)
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=str(e),
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al posponer tomas: {str(e)}",
            )
