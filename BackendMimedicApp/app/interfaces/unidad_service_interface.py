"""
Interfaz simplificada del servicio de unidades
"""
from abc import ABC, abstractmethod
from typing import List, Dict


class IUnidadService(ABC):
    """Interfaz del servicio simplificada de catálogo de unidades"""
    
    @abstractmethod
    def get_or_create(self, nombre: str) -> Dict:
        """Buscar o crear una unidad"""
        pass

    @abstractmethod
    def listar_todas(self) -> List[Dict]:
        """Obtener todas las unidades registradas"""
        pass
