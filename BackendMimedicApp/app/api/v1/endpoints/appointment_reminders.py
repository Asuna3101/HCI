from datetime import datetime
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.api.v1.endpoints.dependencies import get_current_user
from app.controllers.appointment_reminder_controller import AppointmentReminderController
from app.schemas.healthcare import AppointmentReminderCreate, AppointmentReminderOut, StatusIn, AppointmentReminderUpdate, ReminderIdsIn

router = APIRouter()

def _ctl(db: Session) -> AppointmentReminderController:
    return AppointmentReminderController(db)

@router.post("", response_model=AppointmentReminderOut, status_code=status.HTTP_201_CREATED)
def create_appointment_reminder(
    payload: AppointmentReminderCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    return _ctl(db).create(current_user.id, payload)

@router.get("/upcoming", response_model=list[AppointmentReminderOut])
def list_upcoming(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    now = datetime.now()
    return _ctl(db).list_upcoming(current_user.id, now)

@router.get("/history", response_model=list[AppointmentReminderOut])
def list_history(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    now = datetime.now()
    return _ctl(db).list_history(current_user.id, now)

@router.get("", response_model=list[AppointmentReminderOut])
def list_my_appointment_reminders(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    return _ctl(db).list_by_user(current_user.id)

@router.patch("/{reminder_id}/status", status_code=status.HTTP_204_NO_CONTENT)
def set_status(
    reminder_id: int,
    payload: StatusIn,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    _ctl(db).set_status(current_user.id, reminder_id, payload.status)
    return


@router.put("/update/{reminder_id}", response_model=AppointmentReminderOut)
def update_appointment_reminder(
    reminder_id: int,
    payload: AppointmentReminderUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    return _ctl(db).update(current_user.id, reminder_id, payload)

@router.post("/delete", status_code=status.HTTP_204_NO_CONTENT)
def delete_appointment_reminders(
    payload: ReminderIdsIn,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    _ctl(db).delete(current_user.id, payload.reminder_ids)
    return