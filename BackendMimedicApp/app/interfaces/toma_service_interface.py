"""
Interfaz simplificada del servicio de tomas
"""
from abc import ABC, abstractmethod
from typing import Optional
from app.models.toma import Toma


class ITomaService(ABC):
    """Interfaz del servicio simplificada de gestión de tomas"""
    
    @abstractmethod
    def marcar_toma(self, toma_id: int, tomado: bool) -> Optional[Toma]:
        """Marcar una toma como realizada o no realizada"""
        pass
