"""
Modelo de Categoria (para alimentos)
"""
from sqlalchemy import Column, Integer, String, DateTime, func
from sqlalchemy.orm import relationship
from app.core.database import Base


class Categoria(Base):
    __tablename__ = "categorias"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(100), nullable=False, unique=True, index=True)
    createdAt = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updatedAt = Column(DateTime(timezone=True), onupdate=func.now())

    # With the normalized schema, categorias are linked to users' comidas via the
    # join table `comidas_usuario`. Expose that relationship here so we can
    # inspect which user-comidas reference this category.
    comidas = relationship("ComidaUsuario", back_populates="categoria")
