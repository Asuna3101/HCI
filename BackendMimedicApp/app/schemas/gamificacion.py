from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class UserProgressResponse(BaseModel):
    puntos_total: int
    racha_actual: int
    racha_mayor: int

    model_config = {"from_attributes": True}


class LogroResponse(BaseModel):
    id: int
    nombre: str
    descripcion: str
    criterio: str
    desbloqueado: bool
    desbloqueado_en: Optional[datetime] = None
