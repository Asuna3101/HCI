"""
Modelo de Toma (registro de cada dosis programada)
"""
from sqlalchemy import Column, Integer, Boolean, DateTime, ForeignKey, func
from app.core.database import Base


class Toma(Base):
    __tablename__ = "tomas"

    id = Column(Integer, primary_key=True, autoincrement=True)
    idMedxUser = Column(Integer, ForeignKey("medicamento_usuario.id", ondelete="CASCADE"), nullable=False)
    
    tomado = Column(Boolean, default=False, nullable=False)
    adquired = Column(DateTime(timezone=True), nullable=False)  # Fecha/hora programada para tomar
    
    createdAt = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())
