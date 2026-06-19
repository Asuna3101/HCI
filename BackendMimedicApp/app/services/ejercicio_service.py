"""
Servicio de ejercicios
"""
from app.interfaces.ejercicio_repository_interface import IEjercicioRepository
from app.interfaces.ejercicio_service_interface import IEjercicioService

class EjercicioService(IEjercicioService):
    def __init__(self, ej_repo: IEjercicioRepository):
        self.ej_repo = ej_repo
    
    def listar_todos(self):
        ejercicios = self.ej_repo.get_all()
        return [{"id": e.id, "nombre": e.nombre} for e in ejercicios]
