# app/interfaces/appointment_reminder_service_interface.py
from abc import ABC, abstractmethod
from typing import List
from datetime import datetime
from app.models.appointment_reminder import AppointmentReminder

class IAppointmentReminderService(ABC):
    @abstractmethod
    def create(self, *, user_id: int, clinic_id: int, specialty_id: int,
               doctor_id: int, starts_at: datetime, notes: str | None) -> AppointmentReminder:
        pass

    @abstractmethod
    def update(self, *, user_id: int, reminder_id: int, clinic_id: int | None,
               specialty_id: int | None, doctor_id: int | None,
               starts_at: datetime | None, notes: str | None) -> AppointmentReminder:
        pass

    @abstractmethod
    def list_by_user(self, *, user_id: int) -> List[AppointmentReminder]:
        pass

    @abstractmethod
    def delete(self, *, user_id: int, reminder_ids: list[int]) -> None:
        pass
