# app/models/clinic_specialty.py
from sqlalchemy import Column, Integer, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.core.database import Base

class ClinicSpecialty(Base):
    __tablename__ = "clinic_especialidades"

    id = Column(Integer, primary_key=True)
    clinica_id = Column(Integer, ForeignKey("clinicas.id", ondelete="CASCADE"), nullable=False)
    especialidad_id = Column(Integer, ForeignKey("especialidades.id", ondelete="CASCADE"), nullable=False)

    __table_args__ = (UniqueConstraint("clinica_id", "especialidad_id", name="uq_clinica_especialidad"),)

    clinica = relationship("Clinic", back_populates="especialidades")
    especialidad = relationship("Specialty", back_populates="clinicas")
