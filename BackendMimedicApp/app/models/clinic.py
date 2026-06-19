# app/models/clinic_specialty.py
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.core.database import Base

class Clinic(Base):
    __tablename__ = "clinicas"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(120), nullable=False)
    ciudad = Column(String(80), nullable=True)
    direccion = Column(String(200), nullable=True)

    doctores = relationship("Doctor", back_populates="clinica", cascade="all, delete")
    especialidades = relationship("ClinicSpecialty", back_populates="clinica", cascade="all, delete")
