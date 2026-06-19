from datetime import datetime
from typing import List, Literal, Optional
from pydantic import BaseModel


class ReportUser(BaseModel):
  id: int
  nombre: str
  correo: str
  fecha_nacimiento: Optional[datetime] = None
  fecha_creacion: Optional[datetime] = None
  photo: Optional[str] = None
  photo_content_type: Optional[str] = None

class TimelineEvent(BaseModel):
  type: Literal["registro", "medicacion", "toma", "cita", "comida", "ejercicio"]
  title: str
  subtitle: str
  status: Optional[str] = None
  date: datetime

class ReportSummary(BaseModel):
  user: ReportUser
  timeline: List[TimelineEvent]

class CompletedTask(BaseModel):
  title: str
  detail: str
  completed_at: datetime
  status: Optional[str] = None

class CompletedTasksResponse(BaseModel):
  ejercicio: List[CompletedTask]
  medicamentos: List[CompletedTask]
  citas: List[CompletedTask]
