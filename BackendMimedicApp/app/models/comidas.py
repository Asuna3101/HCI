"""
Modelo de Alimento
"""
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, func, Index
from sqlalchemy.orm import relationship
from app.core.database import Base


class Alimento(Base):
    __tablename__ = "comidas"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(200), nullable=False)

    createdAt = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())

    # NOTE: user/category associations were moved to a join table `comidas_usuario`.
    # Keep this model minimal: it represents the global catalog of alimentos.