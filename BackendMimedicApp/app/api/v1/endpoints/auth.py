"""
Endpoint de autenticación (login / register)
"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.factories.service_factory import ServiceFactory
from app.controllers.user_controller import UserController
from app.controllers.recovery_controller import RecoveryController
from app.services.auth_service import AuthService

from app.schemas.user import Token, UserLogin, UserCreate, RecoveryRequest, RecoveryConfirm

router = APIRouter()

@router.post("/login", response_model=Token)
def login(
    user_login: UserLogin,
    db: Session = Depends(get_db)
):
    """Endpoint único para login de usuario"""
    controller = UserController(db)
    
    # Autenticar usuario usando el controlador
    user_data = controller.authenticate_user(user_login.correo, user_login.password)
    
    return user_data


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(user_create: UserCreate, db: Session = Depends(get_db)):
    """
    Registra un nuevo usuario.
    Body esperado:
      {
        "correo": "...",
        "password": "...",
        "nombre": "...",
        "fecha_nacimiento": "YYYY-MM-DD",
        "celular": "..."
      }
    """
    controller = UserController(db)

    # Parsear fecha de nacimiento
    try:
        fecha = datetime.fromisoformat(user_create.fecha_nacimiento).date()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="fecha_nacimiento debe ser YYYY-MM-DD",
        )

    try:
        user = controller.register_user(
            correo=user_create.correo,
            password=user_create.password,
            nombre=user_create.nombre,
            fecha_nacimiento=fecha,
            celular=user_create.celular,
        )
        return {"id": user.id, "correo": user.correo}
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post("/recover/request")
def request_recover(body: RecoveryRequest, db: Session = Depends(get_db)):
    ctl = RecoveryController(db)
    ctl.request(body.email)
    return {"message": "Si el correo existe, se enviará un código de verificación"}


@router.post("/recover/confirm")
def confirm_recover(body: RecoveryConfirm, db: Session = Depends(get_db)):
    ctl = RecoveryController(db)
    ctl.confirm(body.email, body.code, body.new_password)
    return {"message": "Contraseña actualizada"}
