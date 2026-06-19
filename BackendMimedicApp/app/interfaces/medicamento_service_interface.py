"""
Interfaz simplificada de servicio medicamento usuario
"""
from abc import ABC, abstractmethod
from typing import Any, List
from app.models.medicamento import Medicamento

class IMedicamentoService(ABC):
    """Interfaz del servicio simplificada de servicio medicamento"""
    
    @abstractmethod
    def get_or_create(self, nombre: str) -> Medicamento:
        """Registrar o Crear medicamento para un usuario"""
        pass
    
    @abstractmethod
    def listar_todos(self) -> List[dict]:
        """Obtener todos los medicamentos"""
        pass
    
    