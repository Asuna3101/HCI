"""Dependencias compartidas (legacy)

Alinear verificación de token con la usada en los endpoints v1, evitando
inconsistencias en el claim "sub". En lugar de decodificar aquí el JWT y
asumir que "sub" es un entero (id de usuario), delegamos en el controlador,
que usa el servicio de autenticación para decodificar y resolver al usuario
por correo (como emite actualmente el token).
"""
from fastapi import Depends, HTTPException, status, Header
from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.controllers.user_controller import UserController
from app.models.user import User


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Cabecera Authorization inválida",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = authorization.replace("Bearer ", "", 1).strip()

    controller = UserController(db)
    user = controller.get_current_user_from_token(token)
    return user
