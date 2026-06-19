import base64
from fastapi import APIRouter, Depends
from app.api.v1.endpoints.dependencies import get_current_user
from app.schemas.user import UserProfile

router = APIRouter()

@router.get("/me", response_model=UserProfile)
def get_my_profile(user=Depends(get_current_user)):
    """Retorna el perfil del usuario autenticado."""
    photo_b64 = None
    if getattr(user, "photo", None):
        photo_b64 = base64.b64encode(user.photo).decode("utf-8")
    return {
        "id": user.id,
        "nombre": user.nombre,
        "correo": user.correo,
        "celular": user.celular,
        "fecha_nacimiento": user.fecha_nacimiento,
        "photo": photo_b64,
        "photo_content_type": getattr(user, "photo_content_type", None),
    }
