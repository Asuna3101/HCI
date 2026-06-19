"""
Base para todos los modelos
"""
from app.core.database import Base

# Importar todos los modelos aquí para que sean registrados
from app.models.user import User  # noqa
from app.models.medicamento import Medicamento
from app.models.unidad import Unidad
from app.models.medicamentoUsuario import MedicamentoUsuario
from app.models.toma import Toma
from app.models.clinic import Clinic
from app.models.specialty import Specialty
from app.models.doctor import Doctor
from app.models.clinic_specialty import ClinicSpecialty
from app.models.appointment_reminder import AppointmentReminder
from app.models.comidas import Alimento
from app.models.categoria import Categoria
from app.models.comidas_usuario import ComidaUsuario
from app.models.ejercicio import Ejercicio
from app.models.ejercicioUsuario import EjercicioUsuario

