"""
Interfaces de autenticación - Strategy Pattern
"""
from abc import ABC, abstractmethod
from typing import Optional, Any, Union
from datetime import timedelta


class IPasswordHasher(ABC):
    """Interfaz para hashear contraseñas"""
    
    @abstractmethod
    def hash_password(self, password: str) -> str:
        """Hashear contraseña"""
        pass
    
    @abstractmethod
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verificar contraseña"""
        pass


class ITokenGenerator(ABC):
    """Interfaz para generar tokens"""
    
    @abstractmethod
    def create_access_token(self, subject: Union[str, Any], expires_delta: timedelta = None) -> str:
        """Crear token de acceso"""
        pass
    
    @abstractmethod
    def decode_token(self, token: str) -> Optional[dict]:
        """Decodificar token"""
        pass