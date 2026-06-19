"""
Interfaces del repositorio - Inversión de dependencias (DIP)
"""
from abc import ABC, abstractmethod
from typing import Optional, List
from app.models.medicamento import Medicamento


class IMedicamentoRepository(ABC):
    """Interfaz del repositorio de medicamentos"""

    @abstractmethod
    def get_or_create_medicamento(self, medicamento_data: dict) -> Medicamento:
        """Crear medicamento"""
        pass
    
    @abstractmethod
    def get_by_nombre(self, nombre: str) -> Optional[Medicamento]:
        """Obtener medicamento por nombre"""
        pass
    
    @abstractmethod
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Medicamento]:
        """Obtener lista paginada de medicamentos"""
        pass
    