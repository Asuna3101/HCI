# app/seeders/seed_healthcare.py
"""
Recrea catálogos de Salud (clínicas, especialidades, relación y doctores)
y garantiza columnas requeridas en appointment_reminders (p.ej. status).
SOLO para dev.
"""
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker

from app.core.database import engine
from app.models.clinic import Clinic
from app.models.specialty import Specialty
from app.models.clinic_specialty import ClinicSpecialty
from app.models.doctor import Doctor

# Base para create_all()
from app.models import base as models_base
Base = models_base.Base

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# ----------------------------- DDL helpers -----------------------------
def _drop_healthcare_tables():
    """BORRA tablas de salud (solo si drop=True)"""
    with engine.connect() as conn:
        conn.execute(text("DROP TABLE IF EXISTS appointment_reminders CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS citas CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS doctor_disponibilidad CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS doctores CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS clinic_especialidades CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS especialidades CASCADE"))
        conn.execute(text("DROP TABLE IF EXISTS clinicas CASCADE"))
        conn.commit()
    print("🧹 Tablas de salud eliminadas.")


def _create_all_models():
    """Crea tablas según modelos (NO agrega columnas nuevas en tablas existentes)."""
    Base.metadata.create_all(bind=engine)
    print("🏗️ Tablas creadas (según modelos).")


def _ensure_appt_status_column_and_indexes():
    """
    Asegura que appointment_reminders tenga la columna 'status' y los índices requeridos.
    - status: VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE'
    - índice compuesto (user_id, status, starts_at)
    """
    with engine.connect() as conn:
        dialect = conn.dialect.name.lower()

        # 1) Columna status (idempotente)
        if dialect == 'sqlite':
            # SQLite doesn't support ADD COLUMN IF NOT EXISTS. Check via PRAGMA.
            res = conn.execute(text("PRAGMA table_info('appointment_reminders')"))
            # Use mappings() to get dict-like rows portable across SQLAlchemy versions
            rows = res.mappings().all()
            cols = [r.get('name') for r in rows if r.get('name')]
            if 'status' not in cols:
                conn.execute(text("""
                    ALTER TABLE appointment_reminders
                    ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE'
                """))
        else:
            # Other DBs (Postgres, MySQL newer versions) can use IF NOT EXISTS safely
            conn.execute(text("""
                ALTER TABLE appointment_reminders
                ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE'
            """))

        # 2) Backfill por si existieran filas con NULL (por esquemas previos raros)
        conn.execute(text("""
            UPDATE appointment_reminders
            SET status = 'PENDIENTE'
            WHERE status IS NULL
        """))

        # 3) Índice útil para /upcoming (idempotente en PG 9.5+)
        # SQLite and Postgres support CREATE INDEX IF NOT EXISTS
        conn.execute(text("""
            CREATE INDEX IF NOT EXISTS ix_appt_user_status_starts_at
            ON appointment_reminders (user_id, status, starts_at)
        """))

        conn.commit()
    print("🧩 appointment_reminders.status asegurada + índices creados.")


# ----------------------------- SEED -----------------------------
def _seed_catalogs(db):
    # Clínicas
    clinicas_data = [
        dict(nombre="Clínica Ricardo Palma", ciudad="Lima", direccion="Av. Javier Prado Este 1066"),
        dict(nombre="Clínica Internacional", ciudad="Lima", direccion="Av. Alfonso Ugarte 1148"),
        dict(nombre="Clínica San Pablo", ciudad="Lima", direccion="Av. Guardia Civil 385"),
        dict(nombre="Clínica Tezza", ciudad="Lima", direccion="Av. Guardia Civil 337"),
        dict(nombre="Clínica Anglo Americana", ciudad="Lima", direccion="Alfredo Salazar 350"),
    ]
    clinicas = []
    for c in clinicas_data:
        obj = db.query(Clinic).filter(Clinic.nombre == c["nombre"]).first()
        if not obj:
            obj = Clinic(**c)
            db.add(obj)
            db.flush()
            print(f"🏥 Clínica insertada: {obj.nombre}")
        clinicas.append(obj)

    # Especialidades
    nombres_esp = [
        "Reumatología", "Mastología", "Cardiología", "Pediatría",
        "Ginecología", "Traumatología", "Dermatología", "Oftalmología", "Neurología"
    ]
    esp_map = {}
    for n in nombres_esp:
        esp = db.query(Specialty).filter(Specialty.nombre == n).first()
        if not esp:
            esp = Specialty(nombre=n)
            db.add(esp)
            db.flush()
            print(f"📚 Especialidad insertada: {esp.nombre}")
        esp_map[n] = esp

    # Mapeo clínica–especialidad
    mapa = {
        "Clínica Ricardo Palma":  ["Reumatología", "Mastología", "Cardiología"],
        "Clínica Internacional":  ["Ginecología", "Traumatología", "Cardiología"],
        "Clínica San Pablo":      ["Reumatología", "Pediatría", "Traumatología"],
        "Clínica Tezza":          ["Dermatología", "Oftalmología"],
        "Clínica Anglo Americana":["Cardiología", "Neurología", "Reumatología"],
    }
    clinica_by_name = {c.nombre: c for c in clinicas}
    for clinica_nombre, especialidades in mapa.items():
        c = clinica_by_name[clinica_nombre]
        for e_nom in especialidades:
            existe = (
                db.query(ClinicSpecialty)
                .filter(
                    ClinicSpecialty.clinica_id == c.id,
                    ClinicSpecialty.especialidad_id == esp_map[e_nom].id,
                )
                .first()
            )
            if not existe:
                db.add(ClinicSpecialty(clinica_id=c.id, especialidad_id=esp_map[e_nom].id))
                print(f"🔗 Vinculado: {clinica_nombre} ↔ {e_nom}")
    db.flush()

    # Doctores (2 por cada relación clínica–especialidad)
    def make_doctor_name(base, i): return f"Dr(a). {base} {i}"
    for clinica_nombre, especialidades in mapa.items():
        c = clinica_by_name[clinica_nombre]
        for e_nom in especialidades:
            esp = esp_map[e_nom]
            for i in range(1, 3):
                nombre = make_doctor_name(e_nom, i)
                existe = (
                    db.query(Doctor)
                    .filter(
                        Doctor.nombre == nombre,
                        Doctor.clinica_id == c.id,
                        Doctor.especialidad_id == esp.id,
                    )
                    .first()
                )
                if not existe:
                    db.add(Doctor(nombre=nombre, clinica_id=c.id, especialidad_id=esp.id))
                    print(f"🩺 Doctor insertado: {nombre} ({clinica_nombre} / {e_nom})")

    db.commit()
    print("✅ Seed de catálogos de salud completado.")


def _seed_example_appointments(db):
    """
    (Opcional) Citas de ejemplo para probar /upcoming.
    Ajusta el user_id a uno válido en tu BD.
    """
    from datetime import datetime, timedelta
    user_id = 2  # <-- cámbialo por el usuario que uses en tus pruebas

    # Busca un doctor cualquiera
    doc = db.query(Doctor).first()
    if not doc:
        print("⚠️ No hay doctores para crear cita de ejemplo.")
        return

    starts_at_soon = datetime.now().replace(second=0, microsecond=0) + timedelta(minutes=20)
    starts_at_later = datetime.now().replace(second=0, microsecond=0) + timedelta(hours=2)

    # Inserta directo por SQL para no depender de servicios
    db.execute(text("""
        INSERT INTO appointment_reminders (user_id, clinic_id, specialty_id, doctor_id, starts_at, notes, status)
        VALUES (:user_id, :clinic_id, :specialty_id, :doctor_id, :starts_at, :notes, :status)
    """), dict(
        user_id=user_id, clinic_id=doc.clinica_id, specialty_id=doc.especialidad_id,
        doctor_id=doc.id, starts_at=starts_at_soon, notes='Cita de prueba (20m)',
        status='PENDIENTE'
    ))
    db.execute(text("""
        INSERT INTO appointment_reminders (user_id, clinic_id, specialty_id, doctor_id, starts_at, notes, status)
        VALUES (:user_id, :clinic_id, :specialty_id, :doctor_id, :starts_at, :notes, :status)
    """), dict(
        user_id=user_id, clinic_id=doc.clinica_id, specialty_id=doc.especialidad_id,
        doctor_id=doc.id, starts_at=starts_at_later, notes='Cita más tarde',
        status='PENDIENTE'
    ))
    db.commit()
    print("🧪 Citas de ejemplo insertadas.")


def seed_healthcare(drop: bool = False, seed_examples: bool = False):
    """
    Crea (y opcionalmente dropea) tablas de salud y carga catálogos;
    además garantiza columna/índices de appointment_reminders.
    """
    if drop:
        _drop_healthcare_tables()
    _create_all_models()
    _ensure_appt_status_column_and_indexes()

    db = SessionLocal()
    try:
        _seed_catalogs(db)
        if seed_examples:
            _seed_example_appointments(db)
    finally:
        db.close()


if __name__ == "__main__":
    # Cambia flags a voluntad en local:
    seed_healthcare(drop=False, seed_examples=False)
