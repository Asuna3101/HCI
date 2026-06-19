from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory

class MedicamentoController:
    def __init__(self, db: Session):
        med_repo = ServiceFactory.create_medicamento_repository(db)
        self.service = ServiceFactory.create_medicamento_service(med_repo)

    def listar_todos(self):
        try:
            return self.service.listar_todos()
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al obtener medicamentos: {str(e)}"
            )
