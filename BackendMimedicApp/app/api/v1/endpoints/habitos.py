from datetime import date, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Path, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.api.v1.endpoints.dependencies import get_current_user
from app.core.database import get_db
from app.models.habito import Habito, HabitoLog, UserLogro, UserProgress
from app.schemas.habito import (
    CheckInRequest,
    HabitoCreate,
    HabitoLogResponse,
    HabitoResponse,
    HabitoUpdate,
    ProgresoSemanalItem,
)

router = APIRouter()


def _get_or_create_progress(db: Session, usuario_id: int) -> UserProgress:
    progress = (
        db.query(UserProgress)
        .filter(UserProgress.usuario_id == usuario_id)
        .first()
    )

    if not progress:
        progress = UserProgress(usuario_id=usuario_id)
        db.add(progress)
        db.flush()

    return progress


def _update_streak(progress: UserProgress, hoy: date) -> None:
    if progress.ultima_fecha is None:
        progress.racha_actual = 1
    elif progress.ultima_fecha == hoy:
        pass
    elif progress.ultima_fecha == hoy - timedelta(days=1):
        progress.racha_actual += 1
    else:
        progress.racha_actual = 1

    progress.ultima_fecha = hoy

    if progress.racha_actual > progress.racha_mayor:
        progress.racha_mayor = progress.racha_actual


def _check_achievements(
    db: Session,
    usuario_id: int,
    progress: UserProgress,
    hoy: date,
) -> None:
    total_habitos = (
        db.query(func.count(Habito.id))
        .filter(Habito.activo == True)
        .scalar()
        or 0
    )

    completados_hoy = (
        db.query(func.count(HabitoLog.id))
        .filter(
            HabitoLog.usuario_id == usuario_id,
            HabitoLog.fecha == hoy,
        )
        .scalar()
        or 0
    )

    total_logs = (
        db.query(func.count(HabitoLog.id))
        .filter(HabitoLog.usuario_id == usuario_id)
        .scalar()
        or 0
    )

    def _unlock(logro_id: int) -> None:
        already = (
            db.query(UserLogro)
            .filter(
                UserLogro.usuario_id == usuario_id,
                UserLogro.logro_id == logro_id,
            )
            .first()
        )

        if not already:
            db.add(UserLogro(usuario_id=usuario_id, logro_id=logro_id))

    if total_logs >= 1:
        _unlock(1)

    if total_habitos > 0 and completados_hoy >= total_habitos:
        _unlock(2)

    if progress.racha_actual >= 3:
        _unlock(3)

    if progress.racha_actual >= 7:
        _unlock(4)

    if progress.puntos_total >= 1000:
        _unlock(5)


@router.get("/", response_model=List[HabitoResponse])
def get_habitos(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return (
        db.query(Habito)
        .filter(Habito.activo == True)
        .order_by(Habito.id)
        .all()
    )


@router.post("/", response_model=HabitoResponse, status_code=status.HTTP_201_CREATED)
def crear_habito(
    body: HabitoCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    habito = Habito(
        nombre=body.nombre.strip(),
        descripcion=body.descripcion.strip(),
        icono=body.icono.strip() if body.icono else "star",
        puntos_por_completar=body.puntos_por_completar,
        activo=True,
    )

    db.add(habito)
    db.commit()
    db.refresh(habito)

    return habito


@router.put("/{habito_id}", response_model=HabitoResponse)
def actualizar_habito(
    habito_id: int = Path(..., gt=0),
    body: HabitoUpdate = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    habito = db.query(Habito).filter(Habito.id == habito_id).first()

    if not habito:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Hábito no encontrado",
        )

    data = body.model_dump(exclude_unset=True)

    if "nombre" in data and data["nombre"] is not None:
        data["nombre"] = data["nombre"].strip()

    if "descripcion" in data and data["descripcion"] is not None:
        data["descripcion"] = data["descripcion"].strip()

    if "icono" in data and data["icono"] is not None:
        data["icono"] = data["icono"].strip() or "star"

    for key, value in data.items():
        setattr(habito, key, value)

    db.commit()
    db.refresh(habito)

    return habito


@router.delete("/{habito_id}", status_code=status.HTTP_200_OK)
def eliminar_habito(
    habito_id: int = Path(..., gt=0),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    habito = db.query(Habito).filter(Habito.id == habito_id).first()

    if not habito:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Hábito no encontrado",
        )

    habito.activo = False
    db.commit()

    return {"ok": True, "message": "Hábito eliminado correctamente"}


@router.get("/logs", response_model=List[HabitoLogResponse])
def get_logs(
    fecha: str = Query(..., description="YYYY-MM-DD"),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    try:
        fecha_date = date.fromisoformat(fecha)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Formato de fecha inválido (YYYY-MM-DD)",
        )

    logs = (
        db.query(HabitoLog)
        .filter(
            HabitoLog.usuario_id == current_user.id,
            HabitoLog.fecha == fecha_date,
        )
        .all()
    )

    return logs


@router.get("/progreso", response_model=List[ProgresoSemanalItem])
def get_progreso_semanal(
    dias: int = Query(7, ge=1, le=90),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    hoy = date.today()

    total_habitos = (
        db.query(func.count(Habito.id))
        .filter(Habito.activo == True)
        .scalar()
        or 0
    )

    result = []

    for i in range(dias - 1, -1, -1):
        fecha = hoy - timedelta(days=i)

        completados = (
            db.query(func.count(HabitoLog.id))
            .filter(
                HabitoLog.usuario_id == current_user.id,
                HabitoLog.fecha == fecha,
            )
            .scalar()
            or 0
        )

        result.append(
            ProgresoSemanalItem(
                fecha=str(fecha),
                completados=completados,
                total=total_habitos,
            )
        )

    return result


@router.post(
    "/{habito_id}/check-in",
    response_model=HabitoLogResponse,
    status_code=status.HTTP_201_CREATED,
)
def check_in(
    habito_id: int = Path(..., gt=0),
    body: Optional[CheckInRequest] = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    hoy = date.today()

    if body and body.fecha:
        try:
            hoy = date.fromisoformat(body.fecha)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Formato de fecha inválido",
            )

    habito = (
        db.query(Habito)
        .filter(Habito.id == habito_id, Habito.activo == True)
        .first()
    )

    if not habito:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Hábito no encontrado",
        )

    existing = (
        db.query(HabitoLog)
        .filter(
            HabitoLog.usuario_id == current_user.id,
            HabitoLog.habito_id == habito_id,
            HabitoLog.fecha == hoy,
        )
        .first()
    )

    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Hábito ya completado hoy",
        )

    log = HabitoLog(
        usuario_id=current_user.id,
        habito_id=habito_id,
        fecha=hoy,
        puntos_obtenidos=habito.puntos_por_completar,
    )

    db.add(log)
    db.flush()

    progress = _get_or_create_progress(db, current_user.id)

    first_today = (
        db.query(func.count(HabitoLog.id))
        .filter(
            HabitoLog.usuario_id == current_user.id,
            HabitoLog.fecha == hoy,
        )
        .scalar()
        or 0
    )

    if first_today == 1:
        _update_streak(progress, hoy)

    progress.puntos_total += habito.puntos_por_completar

    total_habitos = (
        db.query(func.count(Habito.id))
        .filter(Habito.activo == True)
        .scalar()
        or 0
    )

    if (
        total_habitos > 0
        and first_today >= total_habitos
        and progress.ultimo_bonus_fecha != hoy
    ):
        progress.puntos_total += 20
        progress.ultimo_bonus_fecha = hoy

    _check_achievements(db, current_user.id, progress, hoy)

    db.commit()
    db.refresh(log)

    return log


@router.delete("/{habito_id}/check-in", status_code=status.HTTP_200_OK)
def uncheck(
    habito_id: int = Path(..., gt=0),
    fecha: str = Query(..., description="YYYY-MM-DD"),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    try:
        fecha_date = date.fromisoformat(fecha)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Formato de fecha inválido",
        )

    log = (
        db.query(HabitoLog)
        .filter(
            HabitoLog.usuario_id == current_user.id,
            HabitoLog.habito_id == habito_id,
            HabitoLog.fecha == fecha_date,
        )
        .first()
    )

    if not log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Log no encontrado",
        )

    progress = _get_or_create_progress(db, current_user.id)
    progress.puntos_total = max(0, progress.puntos_total - log.puntos_obtenidos)

    db.delete(log)
    db.commit()

    return {"ok": True}