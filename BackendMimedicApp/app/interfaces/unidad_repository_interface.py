"""
Interfaz del repositorio de unidades - Inversión de dependencias (DIP)
"""
from abc import ABC, abstractmethod
from typing import Optional, List
from app.models.unidad import Unidad


class IUnidadRepository(ABC):
    """Interfaz del repositorio de unidades"""

    @abstractmethod
    def get_by_nombre(self, nombre: str) -> Optional[Unidad]:
        """Obtener unidad por nombre"""
        pass

    @abstractmethod
    def get_or_create_unidad(self, nombre: str) -> Unidad:
        """Buscar o crear una unidad"""
        pass

    @abstractmethod
    def get_all(self) -> List[Unidad]:
        """Obtener todas las unidades ordenadas alfabéticamente"""
        pass
