"""
Repositorio para medicamentos (catálogo global)
"""
from sqlalchemy.orm import Session
from app.interfaces.medicamento_repository_interface import IMedicamentoRepository
from app.models.medicamento import Medicamento


class MedicamentoRepository(IMedicamentoRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_nombre(self, nombre: str) -> Medicamento | None:
        return self.db.query(Medicamento).filter(Medicamento.nombre == nombre).first()

    def get_or_create_medicamento(self, nombre: str) -> Medicamento:
        med = self.get_by_nombre(nombre)
        if not med:
            med = Medicamento(nombre=nombre)
            self.db.add(med)
            self.db.commit()
            self.db.refresh(med)
        return med
    
    def get_all(self, skip: int = 0, limit: int = 100):
        # return self.db.query(Medicamento).order_by(Medicamento.nombre.asc()).all()
        return (
            self.db.query(Medicamento)
            .offset(skip)
            .limit(limit)
            .all()
        )