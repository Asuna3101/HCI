"""
Servicio de catálogo de medicamentos
"""
from app.interfaces.medicamento_repository_interface import IMedicamentoRepository
from app.interfaces.medicamento_service_interface import IMedicamentoService


class MedicamentoService(IMedicamentoService):
    def __init__(self, med_repo: IMedicamentoRepository):
        self.med_repo = med_repo

    def get_or_create(self, nombre: str):
        return self.med_repo.get_or_create_medicamento(nombre)
    
    def listar_todos(self):
        meds = self.med_repo.get_all()
        return [{"id": m.id, "nombre": m.nombre} for m in meds]
