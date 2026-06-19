# app/models/appointment_reminder.py
from sqlalchemy import Column, Integer, ForeignKey, DateTime, String, UniqueConstraint
from sqlalchemy.orm import relationship
from app.core.database import Base

class AppointmentReminder(Base):
    __tablename__ = "appointment_reminders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False, index=True)

    clinic_id    = Column(Integer, ForeignKey("clinicas.id", ondelete="CASCADE"), nullable=False, index=True)
    specialty_id = Column(Integer, ForeignKey("especialidades.id", ondelete="CASCADE"), nullable=False, index=True)
    doctor_id    = Column(Integer, ForeignKey("doctores.id", ondelete="CASCADE"), nullable=False, index=True)

    # Guardamos hora local "tal cual" (sin tz)
    starts_at = Column(DateTime(timezone=False), nullable=False, index=True)
    notes     = Column(String(400), nullable=True)

    # Estado: PENDIENTE | ASISTIDO | NO_ASISTIDO
    status = Column(String(20), nullable=False, server_default="PENDIENTE", default="PENDIENTE", index=True)

    __table_args__ = (
        UniqueConstraint("user_id", "doctor_id", "starts_at", name="uq_user_doctor_start"),
    )

    # Eager loading
    clinic    = relationship("Clinic", lazy="joined")
    specialty = relationship("Specialty", lazy="joined")
    doctor    = relationship("Doctor", back_populates="citas", lazy="joined")
