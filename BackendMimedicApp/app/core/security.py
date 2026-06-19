"""
Utilidades de seguridad simplificadas
"""
import hashlib
from typing import Any, Union
from jose import jwt
from datetime import datetime, timedelta, timezone
from app.core.config import settings



def create_access_token(subject: int | str, expires_delta: timedelta | None = None) -> str:
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    ))
    to_encode = {"sub": str(subject), "exp": expire}
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verificar contraseña con hash simple
    """
    return get_password_hash(plain_password) == hashed_password


def get_password_hash(password: str) -> str:
    """
    Generar hash simple de contraseña con SHA256
    """
    # Hash simple con SHA256 + salt básico
    salt = settings.SECRET_KEY[:16]  # Usar parte del secret key como salt
    return hashlib.sha256((password + salt).encode()).hexdigest()