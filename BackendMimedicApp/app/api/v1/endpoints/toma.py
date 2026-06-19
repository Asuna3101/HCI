"""
Endpoints para tomas (marcar como tomada y limpieza automática)
"""
from fastapi import APIRouter, Depends, Path, Query, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.controllers.toma_controller import TomaController
from app.schemas.toma import TomaUpdate, TomaResponse, TomaWithMedicationResponse
from datetime import datetime, timezone
from typing import List

# Models used to enrich response
from app.models.medicamentoUsuario import MedicamentoUsuario
from app.models.medicamento import Medicamento
from app.models.unidad import Unidad

router = APIRouter()

@router.patch("/{toma_id}", response_model=TomaResponse)
def actualizar_toma(
    toma_id: int = Path(..., gt=0),
    data: TomaUpdate = None,
    db: Session = Depends(get_db),
):
    controller = TomaController(db)
    toma = controller.marcar_toma(toma_id, data.tomado)
    return toma


@router.patch("/{toma_id}/postpone")
def postpone_toma(
    toma_id: int = Path(..., gt=0),
    minutes: int = Query(..., gt=0),
    db: Session = Depends(get_db),
):
    """Pospone la toma indicada y las siguientes del mismo medicamento-usuario
    en `minutes` minutos."""
    controller = TomaController(db)
    try:
        updated = controller.postpone_tomas(toma_id, minutes)
        return {"updated": updated}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/pending", response_model=List[TomaWithMedicationResponse])
def get_pending_tomas(
    at: str | None = Query(None, description="ISO datetime to check (UTC). If omitted uses now UTC"),
    db: Session = Depends(get_db),
):
    """Devuelve las tomas pendientes cuya hora programada cae dentro del
    minuto indicado por `at` (UTC). Si `at` es None, se usa ahora UTC."""
    controller = TomaController(db)
    try:
        if at:
            # Support ISO strings with trailing 'Z' (Zulu) by converting to +00:00
            txt = at
            if txt.endswith('Z'):
                txt = txt[:-1] + '+00:00'
            dt = datetime.fromisoformat(txt)
            # ensure timezone-aware UTC
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            else:
                dt = dt.astimezone(timezone.utc)
        else:
            dt = datetime.now(timezone.utc)

        # use repository to get pending tomas
        repo = controller.service.toma_repo
        tomas = repo.get_pending_at(dt)

        # Enrich each toma with medicamento info via medicamento_usuario -> medicamento -> unidad
        result = []
        for t in tomas:
            medx = db.query(MedicamentoUsuario).filter(MedicamentoUsuario.id == t.idMedxUser).first()
            if medx:
                med = db.query(Medicamento).filter(Medicamento.id == medx.idMedicamento).first()
                uni = db.query(Unidad).filter(Unidad.id == medx.idUnidad).first()
                nombre = med.nombre if med else ""
                dosis = float(medx.dosis) if medx.dosis is not None else 0.0
                unidad = uni.nombre if uni else ""
            else:
                nombre = ""
                dosis = 0.0
                unidad = ""

            result.append({
                "id": t.id,
                "idMedxUser": t.idMedxUser,
                "tomado": t.tomado,
                "adquired": t.adquired,
                "medicamentoNombre": nombre,
                "dosis": dosis,
                "unidad": unidad,
            })

        return result
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
