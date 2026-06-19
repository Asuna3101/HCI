"""
Interfaz para servicio de alimentos
"""
from abc import ABC, abstractmethod
from typing import List
from app.models.comidas import Alimento


class IComidaService(ABC):
    @abstractmethod
    def listar_todas(self, skip: int = 0, limit: int = 100) -> List[Alimento]:
        pass

    @abstractmethod
    def obtener_o_crear(self, nombre: str, detalles: str | None = None) -> Alimento:
        pass

    @abstractmethod
    def obtener_por_id(self, id: int) -> Alimento | None:
        pass

    @abstractmethod
    def listar_por_recomendable(self, recomendable: int, skip: int = 0, limit: int = 100) -> List[Alimento]:
        pass

    @abstractmethod
    def crear(self, nombre: str, detalles: str | None = None) -> Alimento:
        pass

    @abstractmethod
    def actualizar(self, id: int, **kwargs) -> Alimento | None:
        pass

    @abstractmethod
    def eliminar(self, id: int) -> bool:
        pass
