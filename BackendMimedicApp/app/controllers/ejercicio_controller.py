from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory

class EjercicioController:
    def __init__(self, db: Session):
        ej_repo = ServiceFactory.create_ejercicio_repository(db)
        self.service = ServiceFactory.create_ejercicio_service(ej_repo)

    def listar_todos(self):
        try:
            return self.service.listar_todos()
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Error al obtener ejercicios: {str(e)}"
            )