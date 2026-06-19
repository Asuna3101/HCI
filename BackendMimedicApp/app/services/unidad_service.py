"""
Servicio de catálogo de unidades
"""
from app.interfaces.unidad_repository_interface import IUnidadRepository
from app.interfaces.unidad_service_interface import IUnidadService


class UnidadService(IUnidadService):
    def __init__(self, unidad_repo: IUnidadRepository):
        self.unidad_repo = unidad_repo

    def get_or_create(self, nombre: str):
        return self.unidad_repo.get_or_create_unidad(nombre)
    
    def listar_todas(self):
        unidades = self.unidad_repo.get_all()
        return [{"id": u.id, "nombre": u.nombre} for u in unidades]
