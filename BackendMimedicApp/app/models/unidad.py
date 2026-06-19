"""
Modelo de Unidad (ej. mg, ml, pastillas, gotas)
"""
from sqlalchemy import Column, Integer, String, DateTime, func
from app.core.database import Base


class Unidad(Base):
    __tablename__ = "unidades"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(50), nullable=False, unique=True, index=True)
    createdAt = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())
