# app/models/specialty.py
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.core.database import Base

class Specialty(Base):
    __tablename__ = "especialidades"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(120), nullable=False, unique=True)

    clinicas = relationship("ClinicSpecialty", back_populates="especialidad", cascade="all, delete")
