from abc import ABC, abstractmethod
from typing import Optional, List
from app.models.categoria import Categoria


class ICategoriaRepository(ABC):
    @abstractmethod
    def get_by_id(self, id: int) -> Optional[Categoria]:
        pass

    @abstractmethod
    def get_by_nombre(self, nombre: str) -> Optional[Categoria]:
        pass

    @abstractmethod
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Categoria]:
        pass

    @abstractmethod
    def create(self, nombre: str) -> Categoria:
        pass

    @abstractmethod
    def update(self, id: int, nombre: str) -> Categoria | None:
        pass

    @abstractmethod
    def delete(self, id: int) -> bool:
        pass
