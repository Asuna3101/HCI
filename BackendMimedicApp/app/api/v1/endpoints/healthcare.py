# app/api/v1/endpoints/healthcare.py
# Catálogos: clínicas, especialidades por clínica, doctores por clínica+especialidad
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import and_

from app.core.database import get_db
from app.models import clinic as mclinic
from app.models import specialty as mspec
from app.models import clinic_specialty as mcs
from app.models import doctor as mdoc

from app.schemas.healthcare import ClinicOut, SpecialtyOut, DoctorOut

router = APIRouter()

@router.get("/clinicas", response_model=list[ClinicOut])
def list_clinics(db: Session = Depends(get_db)):
    return db.query(mclinic.Clinic).all()


@router.get("/clinicas/{clinica_id}/especialidades", response_model=list[SpecialtyOut])
def list_specialties_by_clinic(clinica_id: int, db: Session = Depends(get_db)):
    q = (
        db.query(mspec.Specialty)
        .join(
            mcs.ClinicSpecialty,
            mcs.ClinicSpecialty.especialidad_id == mspec.Specialty.id,
        )
        .filter(mcs.ClinicSpecialty.clinica_id == clinica_id)
    )
    return q.all()


@router.get("/doctores", response_model=list[DoctorOut])
def list_doctors(
    clinica_id: int = Query(..., description="ID de clínica"),
    especialidad_id: int = Query(..., description="ID de especialidad"),
    db: Session = Depends(get_db),
):
    return (
        db.query(mdoc.Doctor)
        .filter(
            and_(
                mdoc.Doctor.clinica_id == clinica_id,
                mdoc.Doctor.especialidad_id == especialidad_id,
            )
        )
        .all()
    )