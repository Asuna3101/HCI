from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.sql import func
from app.core.database import Base


class Habito(Base):
    __tablename__ = "habitos"
    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(String(200), nullable=False)
    icono = Column(String(50), nullable=False, default="star")
    puntos_por_completar = Column(Integer, default=10)
    activo = Column(Boolean, default=True)


class HabitoLog(Base):
    __tablename__ = "habito_logs"
    id = Column(Integer, primary_key=True, autoincrement=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    habito_id = Column(Integer, ForeignKey("habitos.id"), nullable=False)
    fecha = Column(Date, nullable=False)
    puntos_obtenidos = Column(Integer, default=10)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    __table_args__ = (UniqueConstraint("usuario_id", "habito_id", "fecha", name="uq_habito_log"),)


class UserProgress(Base):
    __tablename__ = "user_progress"
    id = Column(Integer, primary_key=True, autoincrement=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), unique=True, nullable=False)
    puntos_total = Column(Integer, default=0)
    racha_actual = Column(Integer, default=0)
    racha_mayor = Column(Integer, default=0)
    ultima_fecha = Column(Date, nullable=True)
    ultimo_bonus_fecha = Column(Date, nullable=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class Logro(Base):
    __tablename__ = "logros"
    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(String(200), nullable=False)
    criterio = Column(String(50), nullable=False)


class UserLogro(Base):
    __tablename__ = "user_logros"
    id = Column(Integer, primary_key=True, autoincrement=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    logro_id = Column(Integer, ForeignKey("logros.id"), nullable=False)
    fecha_desbloqueo = Column(DateTime(timezone=True), server_default=func.now())
    __table_args__ = (UniqueConstraint("usuario_id", "logro_id", name="uq_user_logro"),)
