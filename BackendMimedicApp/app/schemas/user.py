"""
Esquemas simplificados solo para Login
"""
from pydantic import BaseModel, EmailStr
from datetime import date


# Esquemas para autenticación - Solo lo necesario para login
class Token(BaseModel):
    access_token: str
    token_type: str


class UserLogin(BaseModel):
    correo: EmailStr
    password: str


class UserCreate(BaseModel):
    correo: EmailStr
    password: str
    nombre: str
    fecha_nacimiento: str  # ISO date (YYYY-MM-DD)
    celular: str


class UserProfile(BaseModel):
    id: int
    nombre: str
    correo: EmailStr
    celular: str | None = None
    fecha_nacimiento: date | None = None
    photo: str | None = None
    photo_content_type: str | None = None

    class Config:
        from_attributes = True


class RecoveryRequest(BaseModel):
    email: EmailStr


class RecoveryConfirm(BaseModel):
    email: EmailStr
    code: str
    new_password: str
