# app/models/doctor.py
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class Doctor(Base):
    __tablename__ = "doctores"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(120), nullable=False)

    clinica_id = Column(Integer, ForeignKey("clinicas.id", ondelete="CASCADE"), nullable=False)
    especialidad_id = Column(Integer, ForeignKey("especialidades.id", ondelete="CASCADE"), nullable=False)

    clinica = relationship("Clinic", back_populates="doctores")
    especialidad = relationship("Specialty")

    # Debe existir la clase Appointment y su atributo doctor con back_populates="citas"
    citas = relationship("AppointmentReminder", back_populates="doctor", cascade="all, delete-orphan")
