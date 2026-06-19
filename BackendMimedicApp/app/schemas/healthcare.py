# app/schemas/healthcare.py
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from typing import Literal

# -------- Slims --------
class ClinicOut(BaseModel):
    id: int
    nombre: str
    model_config = ConfigDict(from_attributes=True)

class SpecialtyOut(BaseModel):
    id: int
    nombre: str
    model_config = ConfigDict(from_attributes=True)

class DoctorOut(BaseModel):
    id: int
    nombre: str
    model_config = ConfigDict(from_attributes=True)

# -------- Citas --------
class AppointmentReminderCreate(BaseModel):
    clinic_id: int
    specialty_id: int
    doctor_id: int
    starts_at: datetime  # local, sin tz
    notes: str | None = None


class AppointmentReminderUpdate(BaseModel):
    clinic_id: int | None = None
    specialty_id: int | None = None
    doctor_id: int | None = None
    starts_at: datetime | None = None  # local, sin tz
    notes: str | None = None


class ReminderIdsIn(BaseModel):
    reminder_ids: list[int]

AppointmentStatus = Literal["PENDIENTE", "ASISTIDO", "NO_ASISTIDO"]

class AppointmentReminderOut(BaseModel):
    id: int
    starts_at: datetime
    notes: str | None = None
    status: AppointmentStatus
    clinic: ClinicOut
    specialty: SpecialtyOut
    doctor: DoctorOut
    # Preparado para la lógica de "faltan 30 min"
    is_due_soon: bool = False
    model_config = ConfigDict(from_attributes=True)

class StatusIn(BaseModel):
    status: AppointmentStatus
