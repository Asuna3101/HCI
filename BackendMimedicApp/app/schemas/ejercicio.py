"""
Schemas para ejercicios
"""
from pydantic import BaseModel

class EjercicioCreate(BaseModel):
    nombre: str 

class EjercicioResponse(BaseModel):
    id: int
    nombre: str
    
    class Config:
        from_attributes = True  
