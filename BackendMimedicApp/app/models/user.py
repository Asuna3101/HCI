# app/models/user.py
from sqlalchemy import Boolean, Column, Integer, String, DateTime, Date, Numeric, LargeBinary
from sqlalchemy.sql import func

from app.core.database import Base


class User(Base):
    __tablename__ = "usuarios"

    # Campos según tu esquema
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre = Column(String(50), nullable=False)
    fecha_nacimiento = Column(Date)
    celular = Column(String(20))
    correo = Column(String(50), unique=True, index=True, nullable=False)
    password = Column(String(200))  # Campo original si lo necesitas
    fecha_creacion = Column(DateTime(timezone=True), server_default=func.now())
    hashed_password = Column(String(200), nullable=False)
    photo = Column(LargeBinary, nullable=True)
    photo_content_type = Column(String(50), nullable=True)
    recovery_code = Column(String(10), nullable=True)
    recovery_expires = Column(DateTime(timezone=True), nullable=True)
    
    # Campos adicionales útiles para el sistema
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
