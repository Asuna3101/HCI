"""
Interfaz del repositorio de tomas - Inversión de dependencias (DIP)
"""
from abc import ABC, abstractmethod
from typing import Optional
from app.models.toma import Toma


class ITomaRepository(ABC):
    """Interfaz del repositorio de tomas"""

    @abstractmethod
    def get_by_id(self, toma_id: int) -> Optional[Toma]:
        """Obtener toma por ID"""
        pass

    @abstractmethod
    def update_tomado(self, toma_id: int, tomado: bool) -> Optional[Toma]:
        """Actualizar el estado de una toma (tomado o no tomado)"""
        pass

    @abstractmethod
    def postpone_from(self, toma_id: int, minutes: int) -> int:
        """Aumenta en `minutes` el campo adquired de la toma indicada y de
        todas las tomas siguientes del mismo medicamento-usuario. Devuelve el
        número de tomas actualizadas."""
        pass

    @abstractmethod
    def get_pending_at(self, at_datetime) -> list["Toma"]:
        """Obtiene la lista de tomas pendientes (tomado == False) cuya fecha
        programada (`adquired`) cae dentro del minuto indicado por
        `at_datetime`."""
        pass

    @abstractmethod
    def count_pendientes_by_medxuser(self, medxuser_id: int) -> int:
        """Contar tomas pendientes por medicamento-usuario"""
        pass

    @abstractmethod
    def delete_all_by_medxuser(self, medxuser_id: int) -> int:
        """Eliminar todas las tomas asociadas a un medicamento-usuario"""
        pass
