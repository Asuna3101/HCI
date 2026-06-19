from fastapi import Depends, Header, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.controllers.user_controller import UserController

def get_current_user(
    authorization: str = Header(...),
    db: Session = Depends(get_db)
):
    """Obtiene el usuario autenticado a partir del header Authorization."""
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Cabecera Authorization inválida")

    token = authorization.replace("Bearer ", "")
    controller = UserController(db)
    user = controller.get_current_user_from_token(token)
    return user