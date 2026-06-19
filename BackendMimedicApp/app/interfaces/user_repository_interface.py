"""
Interfaces del repositorio - Inversión de dependencias (DIP)
"""
from abc import ABC, abstractmethod
from typing import Optional, List
from app.models.user import User


class IUserRepository(ABC):
    """Interfaz del repositorio de usuarios"""
    
    @abstractmethod
    def create(self, user_data: dict) -> User:
        """Crear usuario"""
        pass
    
    @abstractmethod
    def get_by_id(self, user_id: int) -> Optional[User]:
        """Obtener usuario por ID"""
        pass
    
    @abstractmethod
    def get_by_email(self, email: str) -> Optional[User]:
        """Obtener usuario por correo"""
        pass
    
    @abstractmethod
    def get_by_correo(self, correo: str) -> Optional[User]:
        """Obtener usuario por correo - método específico"""
        pass
    
    @abstractmethod
    def get_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Obtener lista paginada de usuarios"""
        pass
    
    @abstractmethod
    def update(self, user_id: int, update_data: dict) -> Optional[User]:
        """Actualizar usuario"""
        pass
    
    @abstractmethod
    def delete(self, user_id: int) -> bool:
        """Eliminar usuario"""
        pass
    
    @abstractmethod
    def exists_by_email(self, email: str) -> bool:
        """Verificar si existe usuario con este correo"""
        pass
    
    @abstractmethod
    def exists_by_correo(self, correo: str) -> bool:
        """Verificar si existe usuario con este correo"""
        pass