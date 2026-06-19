"""
Schemas para gestión de tomas 
"""
from pydantic import BaseModel, ConfigDict
from datetime import datetime


class TomaUpdate(BaseModel):
    tomado: bool


class TomaResponse(BaseModel):
    id: int
    idMedxUser: int
    tomado: bool
    adquired: datetime

    model_config = ConfigDict(from_attributes=True)


class TomaWithMedicationResponse(BaseModel):
    id: int
    idMedxUser: int
    tomado: bool
    adquired: datetime

    medicamentoNombre: str
    dosis: float
    unidad: str

    model_config = ConfigDict(from_attributes=True)
