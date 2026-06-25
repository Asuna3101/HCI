from pydantic import BaseModel
from datetime import date
from typing import Optional


class HabitoResponse(BaseModel):
    id: int
    nombre: str
    descripcion: str
    icono: str
    puntos_por_completar: int
    activo: bool

    model_config = {"from_attributes": True}


class HabitoLogResponse(BaseModel):
    id: int
    habito_id: int
    fecha: date
    puntos_obtenidos: int
    completado: bool = True

    model_config = {"from_attributes": True}


class CheckInRequest(BaseModel):
    fecha: Optional[str] = None


class ProgresoSemanalItem(BaseModel):
    fecha: str
    completados: int
    total: int
