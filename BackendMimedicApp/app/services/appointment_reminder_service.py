from datetime import timedelta, datetime
from fastapi import HTTPException
from app.repositories.appointment_reminder_repo import AppointmentReminderRepository, DUE_SOON_WINDOW

WINDOW = timedelta(minutes=15)

def _naive(dt: datetime) -> datetime:

    return dt.replace(tzinfo=None) if (dt.tzinfo is not None and dt.tzinfo.utcoffset(dt) is not None) else dt

class AppointmentReminderService:
    def __init__(self, db):
        self.repo = AppointmentReminderRepository(db)

    def create(self, *, user_id: int, clinic_id: int, specialty_id: int,
               doctor_id: int, starts_at: datetime, notes: str | None):
        if self.repo.find_user_doctor_same_time(user_id, doctor_id, starts_at):
            raise HTTPException(status_code=409, detail="Ya registraste esa cita con ese doctor a esa hora.")
        if self.repo.find_doctor_in_window(doctor_id, starts_at, WINDOW):
            raise HTTPException(status_code=409, detail="Otra cita para el mismo doctor dentro de ±15 minutos.")
        return self.repo.create(
            user_id=user_id, clinic_id=clinic_id, specialty_id=specialty_id,
            doctor_id=doctor_id, starts_at=starts_at, notes=notes,
        )

    def list_upcoming(self, *, user_id: int, now: datetime):
        # Asegura coherencia: comparaciones en naive/local
        now_n = _naive(now)
        items = self.repo.list_upcoming_by_user(user_id, now_n)
        soon_hi = now_n + DUE_SOON_WINDOW
        for x in items:
            xs = _naive(x.starts_at)
            x.is_due_soon = (now_n <= xs <= soon_hi)
        return items

    def list_history(self, *, user_id: int, now: datetime):
        # Por consistencia, pasa naive al repo también
        return self.repo.list_history_by_user(user_id, _naive(now))

    def delete(self, *, user_id: int, reminder_ids: list[int]):
        invalid: list[int] = []
        objs_to_delete: list = []

        for rid in reminder_ids:
            obj = self.repo.get(rid)
            if not obj or obj.user_id != user_id:
                invalid.append(rid)
            else:
                objs_to_delete.append(obj)

        if invalid:
            # Mostrar las ids que no se pudieron borrar por no existir o no pertenecer
            raise HTTPException(status_code=404, detail={"not_found_or_forbidden_ids": invalid})

        for obj in objs_to_delete:
            self.repo.delete(obj)

    def set_status(self, *, user_id: int, reminder_id: int, status: str):
        if status not in ("PENDIENTE", "ASISTIDO", "NO_ASISTIDO"):
            raise HTTPException(status_code=400, detail="Estado inválido")
        obj = self.repo.get(reminder_id)
        if not obj or obj.user_id != user_id:
            raise HTTPException(status_code=404, detail="No encontrado")
        return self.repo.set_status(obj, status)

    def update(self, *, user_id: int, reminder_id: int, clinic_id: int | None,
               specialty_id: int | None, doctor_id: int | None,
               starts_at: datetime | None, notes: str | None):
        obj = self.repo.get(reminder_id)
        if not obj or obj.user_id != user_id:
            raise HTTPException(status_code=404, detail="No encontrado")

        update_data: dict = {}

        # compute target values for validation
        target_doctor = doctor_id if doctor_id is not None else obj.doctor_id
        target_start = _naive(starts_at) if starts_at is not None else _naive(obj.starts_at)

        # If starts_at provided or doctor changed, check conflicts
        if starts_at is not None or doctor_id is not None:
            # check same user + doctor + same time (ignore self)
            other = self.repo.find_user_doctor_same_time(user_id, target_doctor, target_start)
            if other and getattr(other, "id", None) != getattr(obj, "id", None):
                raise HTTPException(status_code=409, detail="Ya registraste esa cita con ese doctor a esa hora.")

            # check doctor in ±WINDOW minutes (ignore self)
            other2 = self.repo.find_doctor_in_window(target_doctor, target_start, WINDOW)
            if other2 and getattr(other2, "id", None) != getattr(obj, "id", None):
                raise HTTPException(status_code=409, detail="Otra cita para el mismo doctor dentro de ±15 minutos.")

        # Prepare update_data dict with provided fields
        if clinic_id is not None:
            update_data["clinic_id"] = clinic_id
        if specialty_id is not None:
            update_data["specialty_id"] = specialty_id
        if doctor_id is not None:
            update_data["doctor_id"] = doctor_id
        if starts_at is not None:
            update_data["starts_at"] = starts_at
        if notes is not None:
            update_data["notes"] = notes

        # If no fields to update, simply return the current object
        if not update_data:
            return obj

        updated = self.repo.update(reminder_id, update_data)
        if not updated:
            # unlikely because we fetched earlier, but be defensive
            raise HTTPException(status_code=404, detail="No encontrado")
        return updated
