"""
Repositorio de Usuario - Capa de acceso a datos
Implementa IUserRepository (LSP - Liskov Substitution Principle)
"""
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError

from app.models.user import User
from app.interfaces.user_repository_interface import IUserRepository


class UserRepository(IUserRepository):
    """Repositorio para operaciones de base de datos de usuarios"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, user_data: dict) -> User:
        """Crear usuario en la base de datos"""
        try:
            db_user = User(**user_data)
            self.db.add(db_user)
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except IntegrityError:
            self.db.rollback()
            raise ValueError("Usuario ya existe")
    
    def get_by_id(self, user_id: int) -> Optional[User]:
        """Obtener usuario por ID"""
        return self.db.query(User).filter(User.id == user_id).first()
    
    def get_by_email(self, email: str) -> Optional[User]:
        """Obtener usuario por correo"""
        return self.db.query(User).filter(User.correo == email).first()
    
    def get_by_correo(self, correo: str) -> Optional[User]:
        """Obtener usuario por correo - método específico"""
        return self.db.query(User).filter(User.correo == correo).first()
    
    def get_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Obtener lista paginada de usuarios"""
        return (
            self.db.query(User)
            .offset(skip)
            .limit(limit)
            .all()
        )
    
    def update(self, user_id: int, update_data: dict) -> Optional[User]:
        """Actualizar usuario"""
        try:
            db_user = self.get_by_id(user_id)
            if not db_user:
                return None
            
            for field, value in update_data.items():
                setattr(db_user, field, value)
            
            self.db.commit()
            self.db.refresh(db_user)
            return db_user
        except IntegrityError:
            self.db.rollback()
            raise ValueError("Error al actualizar usuario")
    
    def delete(self, user_id: int) -> bool:
        """Eliminar usuario"""
        db_user = self.get_by_id(user_id)
        if not db_user:
            return False
        
        self.db.delete(db_user)
        self.db.commit()
        return True
    
    def exists_by_email(self, email: str) -> bool:
        """Verificar si existe usuario con este correo"""
        return self.db.query(User).filter(User.correo == email).first() is not None
    
    def exists_by_correo(self, correo: str) -> bool:
        """Verificar si existe usuario con este correo"""
        return self.db.query(User).filter(User.correo == correo).first() is not None