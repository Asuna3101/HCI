"""
Schemas para registro de medicamentos asociados a usuarios
"""
from pydantic import BaseModel
from datetime import datetime


class MedicamentoUsuarioCreate(BaseModel):
    nombre: str
    dosis: float
    unidad: str
    frecuencia_horas: float
    fecha_inicio: datetime
    fecha_fin: datetime

