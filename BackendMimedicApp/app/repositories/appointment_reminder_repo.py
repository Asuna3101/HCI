# app/repositories/appointment_reminder_repo.py
from datetime import datetime, timedelta
from sqlalchemy.orm import Session, joinedload
from app.models.appointment_reminder import AppointmentReminder

DUE_SOON_WINDOW = timedelta(minutes=30)

class AppointmentReminderRepository:
    def __init__(self, db: Session):
        self.db = db

    def find_user_doctor_same_time(self, user_id: int, doctor_id: int, starts_at: datetime):
        return (self.db.query(AppointmentReminder)
                .filter(AppointmentReminder.user_id == user_id,
                        AppointmentReminder.doctor_id == doctor_id,
                        AppointmentReminder.starts_at == starts_at)
                .first())

    def find_doctor_in_window(self, doctor_id: int, starts_at: datetime, window: timedelta):
        low, high = starts_at - window, starts_at + window
        return (self.db.query(AppointmentReminder)
                .filter(AppointmentReminder.doctor_id == doctor_id,
                        AppointmentReminder.starts_at.between(low, high))
                .first())

    def create(self, *, user_id: int, clinic_id: int, specialty_id: int,
               doctor_id: int, starts_at: datetime, notes: str | None):
        obj = AppointmentReminder(
            user_id=user_id,
            clinic_id=clinic_id,
            specialty_id=specialty_id,
            doctor_id=doctor_id,
            starts_at=starts_at,
            notes=notes,
            status="PENDIENTE",  # default explícito
        )
        self.db.add(obj)
        self.db.commit()
        self.db.refresh(obj)
        return obj

    # Próximas (PENDIENTE y en el futuro)
    def list_upcoming_by_user(self, user_id: int, now: datetime):
        q = (self.db.query(AppointmentReminder)
             .options(
                 joinedload(AppointmentReminder.clinic),
                 joinedload(AppointmentReminder.specialty),
                 joinedload(AppointmentReminder.doctor),
             )
             .filter(AppointmentReminder.user_id == user_id,
                     AppointmentReminder.status == "PENDIENTE",
                     AppointmentReminder.starts_at >= now)
             .order_by(AppointmentReminder.starts_at.asc()))
        return q.all()

    # Historial (ASISTIDO / NO_ASISTIDO, o ya pasó)
    def list_history_by_user(self, user_id: int, now: datetime):
        q = (self.db.query(AppointmentReminder)
             .options(
                 joinedload(AppointmentReminder.clinic),
                 joinedload(AppointmentReminder.specialty),
                 joinedload(AppointmentReminder.doctor),
             )
             .filter(
                 AppointmentReminder.user_id == user_id,
                 # si quedó PENDIENTE pero ya pasó, también lo consideramos historial "por tiempo"
                 ((AppointmentReminder.status != "PENDIENTE") |
                  (AppointmentReminder.starts_at < now))
             )
             .order_by(AppointmentReminder.starts_at.desc()))
        return q.all()

    def get(self, reminder_id: int):
        return self.db.get(AppointmentReminder, reminder_id)


    def set_status(self, obj: AppointmentReminder, status: str):
        obj.status = status
        self.db.add(obj)
        self.db.commit()
        self.db.refresh(obj)
        return obj

    def update(self, reminder_id: int, update_data: dict):
        obj = self.get(reminder_id)
        if not obj:
            return None

        for field, value in update_data.items():
            if hasattr(obj, field):
                setattr(obj, field, value)

        self.db.commit()
        self.db.refresh(obj)
        return obj

    def delete(self, obj: AppointmentReminder):
        self.db.delete(obj)
        self.db.commit()
