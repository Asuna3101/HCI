"""
Repositorio para unidades (catálogo global)
"""
from sqlalchemy.orm import Session
from app.interfaces.unidad_repository_interface import IUnidadRepository
from app.models.unidad import Unidad


class UnidadRepository(IUnidadRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_nombre(self, nombre: str) -> Unidad | None:
        return self.db.query(Unidad).filter(Unidad.nombre == nombre).first()

    def get_or_create_unidad(self, nombre: str) -> Unidad:
        unidad = self.get_by_nombre(nombre)
        if not unidad:
            unidad = Unidad(nombre=nombre)
            self.db.add(unidad)
            self.db.commit()
            self.db.refresh(unidad)
        return unidad
    
    def get_all(self):
        return self.db.query(Unidad).order_by(Unidad.nombre.asc()).all()
