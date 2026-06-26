from datetime import date
from typing import Optional

from pydantic import BaseModel, Field


class HabitoCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=100)
    descripcion: str = Field(..., min_length=2, max_length=200)
    icono: str = Field(default="star", max_length=50)
    puntos_por_completar: int = Field(default=10, ge=1, le=100)


class HabitoUpdate(BaseModel):
    nombre: Optional[str] = Field(default=None, min_length=2, max_length=100)
    descripcion: Optional[str] = Field(default=None, min_length=2, max_length=200)
    icono: Optional[str] = Field(default=None, max_length=50)
    puntos_por_completar: Optional[int] = Field(default=None, ge=1, le=100)
    activo: Optional[bool] = None


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