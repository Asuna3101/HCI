"""
Modelo de relación MedicamentoUsuario
"""
from sqlalchemy import Column, Integer, ForeignKey, DateTime, func, Float
from app.core.database import Base


class MedicamentoUsuario(Base):
    __tablename__ = "medicamento_usuario"

    id = Column(Integer, primary_key=True, autoincrement=True)
    idUsuario = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    idMedicamento = Column(Integer, ForeignKey("medicamentos.id", ondelete="CASCADE"), nullable=False)
    idUnidad = Column(Integer, ForeignKey("unidades.id", ondelete="CASCADE"), nullable=False)
    
    dosis = Column(Float, nullable=False)
    frecuencia_horas = Column(Float, nullable=False)
    fecha_inicio = Column(DateTime(timezone=True), nullable=False)
    fecha_fin = Column(DateTime(timezone=True), nullable=False)

    createdAt = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())
