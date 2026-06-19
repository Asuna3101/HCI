"""
Servicio de Autenticación - SRP (Single Responsibility Principle)
Solo se encarga de la lógica de autenticación y tokens
"""
from datetime import timedelta
from typing import Optional

from fastapi import HTTPException, status

from app.interfaces.user_service_interface import IUserService
from app.models.user import User
from app.interfaces.user_repository_interface import IUserRepository
from app.interfaces.auth_interface import ITokenGenerator, IPasswordHasher


class AuthService:
    """Servicio dedicado a autenticación (verificación y emisión de tokens)"""

    def __init__(self, user_service: IUserService, token_generator: ITokenGenerator):
        self.user_service = user_service
        self.token_generator = token_generator
    
    def authenticate_and_create_token(
        self,
        correo: str,
        password: str,
        expires_delta: Optional[timedelta] = None
    ) -> Optional[dict]:
        """
        Autentica usuario y genera token
        Retorna None si las credenciales son inválidas
        """
        # Autenticar usuario
        user = self.user_service.authenticate_user(correo, password)
        if not user:
            return None

        # Generar token
        access_token = self.token_generator.create_access_token(
            subject=user.correo,
            expires_delta=expires_delta
        )

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user
        }


    def verify_token(self, token: str) -> Optional[str]:
        """
        Verificar token y extraer username
        """
        payload = self.token_generator.decode_token(token)
        if not payload:
            return None

        return payload.get("sub")


    def refresh_token(self, user: User, expires_delta: Optional[timedelta] = None) -> str:
        return self.token_generator.create_access_token(
            subject=user.id,           # <-- idem
            expires_delta=expires_delta,
        )

    def refresh_token(self, user: User, expires_delta: Optional[timedelta] = None) -> str:
        """
        Generar nuevo token para usuario existente
        """
        return self.token_generator.create_access_token(
            subject=user.correo,
            expires_delta=expires_delta
        )

    def get_user_from_token(self, token: str) -> Optional[User]:
        email = self.verify_token(token)
        if not email:
            return None

        user = self.user_service.get_user_by_email(email)
        return user
