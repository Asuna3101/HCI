from abc import ABC, abstractmethod
from typing import List
from app.models.categoria import Categoria


class ICategoriaService(ABC):
    @abstractmethod
    def listar_todas(self, skip: int = 0, limit: int = 100) -> List[Categoria]:
        pass

    @abstractmethod
    def obtener_por_id(self, id: int):
        pass

    @abstractmethod
    def crear(self, nombre: str):
        pass

    @abstractmethod
    def actualizar(self, id: int, nombre: str):
        pass

    @abstractmethod
    def eliminar(self, id: int):
        pass
