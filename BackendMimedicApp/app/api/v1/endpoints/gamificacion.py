from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.v1.endpoints.dependencies import get_current_user
from app.core.database import get_db
from app.models.habito import Logro, UserLogro, UserProgress
from app.schemas.gamificacion import LogroResponse, UserProgressResponse

router = APIRouter()


@router.get("/progreso", response_model=UserProgressResponse)
def get_progreso(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    progress = db.query(UserProgress).filter(UserProgress.usuario_id == current_user.id).first()
    if not progress:
        return UserProgressResponse(puntos_total=0, racha_actual=0, racha_mayor=0)
    return progress


@router.get("/logros", response_model=List[LogroResponse])
def get_logros(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    logros = db.query(Logro).order_by(Logro.id).all()
    desbloqueados = {
        ul.logro_id: ul.fecha_desbloqueo
        for ul in db.query(UserLogro).filter(UserLogro.usuario_id == current_user.id).all()
    }

    return [
        LogroResponse(
            id=logro.id,
            nombre=logro.nombre,
            descripcion=logro.descripcion,
            criterio=logro.criterio,
            desbloqueado=logro.id in desbloqueados,
            desbloqueado_en=desbloqueados.get(logro.id),
        )
        for logro in logros
    ]
