from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class CategoriaOut(BaseModel):
    id: int
    nombre: str
    createdAt: Optional[datetime]

    class Config:
        orm_mode = True


class CategoriaCreate(BaseModel):
    nombre: str
