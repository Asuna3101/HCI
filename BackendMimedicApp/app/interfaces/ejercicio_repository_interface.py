from abc import ABC, abstractmethod
from typing import Optional, List
from app.models.ejercicio import Ejercicio


class IEjercicioRepository(ABC):
    """Interfaz del repositorio de ejercicios"""

    @abstractmethod
    def get_or_create_ejercicio(self, nombre: str) -> Ejercicio:
        """Crear ejercicio"""
        pass
    
    @abstractmethod
    def get_by_nombre(self, nombre: str) -> Optional[Ejercicio]:
        """Obtener ejercicio por nombre"""
        pass
    
    @abstractmethod
    def get_by_id(self, id_ejercicio: int) -> Optional[Ejercicio]:
        """Obtener ejercicio por ID"""
        pass
    
    @abstractmethod
    def get_all(self, skip: int = 0, limit: int = 100) -> List[Ejercicio]:
        """Obtener lista de ejercicios"""
        pass