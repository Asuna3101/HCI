from sqlalchemy.orm import Session
from app.interfaces.categoria_repository_interface import ICategoriaRepository
from app.models.categoria import Categoria


class CategoriaRepository(ICategoriaRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, id: int) -> Categoria | None:
        return self.db.query(Categoria).filter(Categoria.id == id).first()

    def get_by_nombre(self, nombre: str) -> Categoria | None:
        return self.db.query(Categoria).filter(Categoria.nombre == nombre).first()

    def get_all(self, skip: int = 0, limit: int = 100):
        return self.db.query(Categoria).offset(skip).limit(limit).all()

    def create(self, nombre: str) -> Categoria:
        cat = Categoria(nombre=nombre)
        self.db.add(cat)
        self.db.commit()
        self.db.refresh(cat)
        return cat

    def update(self, id: int, nombre: str) -> Categoria | None:
        cat = self.get_by_id(id)
        if not cat:
            return None
        cat.nombre = nombre
        self.db.commit()
        self.db.refresh(cat)
        return cat

    def delete(self, id: int) -> bool:
        cat = self.get_by_id(id)
        if not cat:
            return False
        self.db.delete(cat)
        self.db.commit()
        return True
