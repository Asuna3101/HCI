"""
Repositorio para alimentos (catálogo global)
"""
from sqlalchemy.orm import Session
from app.interfaces.comida_repository_interface import IComidaRepository
from app.models.comidas import Alimento


class ComidaRepository(IComidaRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_nombre(self, nombre: str) -> Alimento | None:
        return self.db.query(Alimento).filter(Alimento.nombre == nombre).first()

    def get_by_id(self, id: int) -> Alimento | None:
        return self.db.query(Alimento).filter(Alimento.id == id).first()

    def get_or_create_alimento(self, nombre: str, detalles: str | None = None) -> Alimento:
        alm = self.get_by_nombre(nombre)
        if not alm:
            alm = Alimento(nombre=nombre)
            self.db.add(alm)
            self.db.commit()
            self.db.refresh(alm)
        return alm

    def create(self, nombre: str, detalles: str | None = None) -> Alimento:
        alm = Alimento(nombre=nombre)
        self.db.add(alm)
        self.db.commit()
        self.db.refresh(alm)
        return alm

    def update(self, id: int, **kwargs) -> Alimento | None:
        alm = self.get_by_id(id)
        if not alm:
            return None
        for k, v in kwargs.items():
            if hasattr(alm, k) and v is not None:
                setattr(alm, k, v)
        self.db.commit()
        self.db.refresh(alm)
        return alm

    def delete(self, id: int) -> bool:
        alm = self.get_by_id(id)
        if not alm:
            return False
        self.db.delete(alm)
        self.db.commit()
        return True

    def get_all(self, skip: int = 0, limit: int = 100):
        return (
            self.db.query(Alimento)
            .order_by(Alimento.nombre.asc())
            .offset(skip)
            .limit(limit)
            .all()
        )

    def search_by_nombre(self, query: str, limit: int = 20) -> list[Alimento]:
        """Busca comidas por nombre usando LIKE (case-insensitive)"""
        search_pattern = f"%{query}%"
        return (
            self.db.query(Alimento)
            .filter(Alimento.nombre.ilike(search_pattern))
            .order_by(Alimento.nombre.asc())
            .limit(limit)
            .all()
        )

    def get_by_recomendable(self, recomendable: int, skip: int = 0, limit: int = 100):
        # With the normalized schema, 'recomendable' is stored per-user in comidas_usuario.
        # This repository does not support global recomendable filtering.
        return []
