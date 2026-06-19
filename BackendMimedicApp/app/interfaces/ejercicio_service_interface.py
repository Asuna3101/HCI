from abc import ABC, abstractmethod
from typing import List
from app.models.ejercicio import Ejercicio

class IEjercicioService(ABC):
    """Interfaz del servicio de servicio ejercicio"""
    
    @abstractmethod
    def listar_todos(self) -> List[Ejercicio]:
        """Obtener todos los ejercicios"""
        pass