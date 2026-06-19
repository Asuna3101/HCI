"""
Implementación concreta de generación de tokens JWT
Strategy Pattern - Diferentes estrategias de tokens
"""
from datetime import datetime, timedelta
from typing import Any, Union, Optional
from jose import jwt, JWTError
from app.interfaces.auth_interface import ITokenGenerator
from app.core.config import settings


class JWTTokenGenerator(ITokenGenerator):
    """Implementación de tokens con JWT"""
    
    def __init__(self):
        self.secret_key = settings.SECRET_KEY
        self.algorithm = settings.ALGORITHM
        self.access_token_expire_minutes = settings.ACCESS_TOKEN_EXPIRE_MINUTES
    
    def create_access_token(self, subject: Union[str, Any], expires_delta: timedelta = None) -> str:
        """Crear token JWT de acceso"""
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=self.access_token_expire_minutes)
        
        to_encode = {"exp": expire, "sub": str(subject)}
        encoded_jwt = jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)
        return encoded_jwt
    
    def decode_token(self, token: str) -> Optional[dict]:
        """Decodificar token JWT"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
        except JWTError:
            return None


class MockTokenGenerator(ITokenGenerator):
    """Implementación mock para testing"""
    
    def create_access_token(self, subject: Union[str, Any], expires_delta: timedelta = None) -> str:
        """Crear token mock para testing"""
        return f"mock_token_{subject}"
    
    def decode_token(self, token: str) -> Optional[dict]:
        """Decodificar token mock"""
        if token.startswith("mock_token_"):
            username = token.replace("mock_token_", "")
            return {"sub": username}
        return None