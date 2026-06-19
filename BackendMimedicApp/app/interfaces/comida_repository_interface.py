"""
Interfaz del repositorio de alimentos
"""
from abc import ABC, abstractmethod
from typing import Optional, List
from app.models.comidas import Alimento


class IComidaRepository(ABC):
    @abstractmethod
    def get_by_nombre(self, nombre: str) -> Optional[Alimento]:
        pass

    @abstractmethod
    def get_or_create_alimento(self, nombre: str, detalles: str | None = None) -> Alimento:
        pass

    @abstractmethod
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Alimento]:
        pass

    @abstractmethod
    def get_by_id(self, id: int) -> Optional[Alimento]:
        pass

    @abstractmethod
    def get_by_recomendable(self, recomendable: int, skip: int = 0, limit: int = 100) -> List[Alimento]:
        pass

    @abstractmethod
    def search_by_nombre(self, query: str, limit: int = 20) -> List[Alimento]:
        """Busca comidas por nombre usando LIKE (case-insensitive)"""
        pass

    @abstractmethod
    def create(self, nombre: str, detalles: str | None = None) -> Alimento:
        pass

    @abstractmethod
    def update(self, id: int, **kwargs) -> Optional[Alimento]:
        pass

    @abstractmethod
    def delete(self, id: int) -> bool:
        pass
