# app/interfaces/appointment_reminder_repository_interface.py
from abc import ABC, abstractmethod
from typing import Optional, List
from datetime import datetime, timedelta
from app.models.appointment_reminder import AppointmentReminder

class IAppointmentReminderRepository(ABC):
    @abstractmethod
    def find_user_doctor_same_time(self, user_id: int, doctor_id: int, starts_at: datetime) -> Optional[AppointmentReminder]:
        pass

    @abstractmethod
    def find_doctor_in_window(self, doctor_id: int, starts_at: datetime, window: timedelta) -> Optional[AppointmentReminder]:
        pass

    @abstractmethod
    def create(self, *, user_id: int, clinic_id: int, specialty_id: int,
               doctor_id: int, starts_at: datetime, notes: str | None) -> AppointmentReminder:
        pass

    @abstractmethod
    def update(self, reminder_id: int, update_data: dict) -> Optional[AppointmentReminder]:
        pass

    @abstractmethod
    def list_by_user(self, user_id: int) -> List[AppointmentReminder]:
        pass

    @abstractmethod
    def get(self, reminder_id: int) -> Optional[AppointmentReminder]:
        pass

    @abstractmethod
    def delete(self, obj: AppointmentReminder) -> None:
        pass
