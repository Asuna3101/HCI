from sqlalchemy.orm import Session
from app.interfaces.ejercicio_repository_interface import IEjercicioRepository
from app.models.ejercicio import Ejercicio


class EjercicioRepository(IEjercicioRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_nombre(self, nombre: str) -> Ejercicio | None:
        return self.db.query(Ejercicio).filter(Ejercicio.nombre == nombre).first()
    
    def get_by_id(self, id_ejercicio) -> Ejercicio | None:
        return self.db.query(Ejercicio).filter(Ejercicio.id == id_ejercicio).first()

    def get_or_create_ejercicio(self, nombre: str) -> Ejercicio:
        ej = self.get_by_nombre(nombre)
        if not ej:
            ej = Ejercicio(nombre=nombre)
            self.db.add(ej)
            self.db.commit()
            self.db.refresh(ej)
        return ej

    def get_all(self, skip: int = 0, limit: int = 100):
        return (
            self.db.query(Ejercicio)
            .offset(skip)
            .limit(limit)
            .all()
        )