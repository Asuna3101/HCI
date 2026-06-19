"""
Interfaz simplificada solo para autenticación
"""
from abc import ABC, abstractmethod
from typing import Optional
from app.models.user import User


class IUserService(ABC):
    """Interfaz del servicio simplificada solo para login"""
    
    @abstractmethod
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Obtener usuario por email"""
        pass
    
    @abstractmethod
    def authenticate_user(self, username_or_email: str, password: str) -> Optional[User]:
        """Autenticar usuario"""
        pass