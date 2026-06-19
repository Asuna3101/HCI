from datetime import datetime
from sqlalchemy.orm import Session
from app.services.appointment_reminder_service import AppointmentReminderService
from app.schemas.healthcare import AppointmentReminderCreate, AppointmentReminderUpdate

class AppointmentReminderController:

    def __init__(self, db: Session):
        self.svc = AppointmentReminderService(db)

    # Crear
    def create(self, user_id: int, data: AppointmentReminderCreate):
        return self.svc.create(
            user_id=user_id,
            clinic_id=data.clinic_id,
            specialty_id=data.specialty_id,
            doctor_id=data.doctor_id,
            starts_at=data.starts_at,  # local (sin tz), consistente con tu modelo
            notes=data.notes,
        )

    # Próximas
    def list_upcoming(self, user_id: int, now: datetime):
        return self.svc.list_upcoming(user_id=user_id, now=now)

    # Historial
    def list_history(self, user_id: int, now: datetime):
        return self.svc.list_history(user_id=user_id, now=now)

    # Todas por usuario (si quieres mantenerlo)
    def list_by_user(self, user_id: int):
        return self.svc.list_by_user(user_id=user_id)

    # Cambiar estado
    def set_status(self, user_id: int, reminder_id: int, status: str):
        return self.svc.set_status(user_id=user_id, reminder_id=reminder_id, status=status)

    # Eliminar
    def delete(self, user_id: int, reminder_ids: list[int]):
        return self.svc.delete(user_id=user_id, reminder_ids=reminder_ids)

    # Actualizar
    def update(self, user_id: int, reminder_id: int, data: AppointmentReminderUpdate):
        return self.svc.update(
            user_id=user_id,
            reminder_id=reminder_id,
            clinic_id=data.clinic_id,
            specialty_id=data.specialty_id,
            doctor_id=data.doctor_id,
            starts_at=data.starts_at,
            notes=data.notes,
        )
