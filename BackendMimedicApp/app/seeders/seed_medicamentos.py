from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.medicamento import Medicamento

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def seed_medicamentos():
    db = SessionLocal()
    medicamentos = [
        "Paracetamol",
        "Ibuprofeno",
        "Amoxicilina",
        "Omeprazol",
        "Loratadina",
    ]
    for nombre in medicamentos:
        existe = db.query(Medicamento).filter(Medicamento.nombre == nombre).first()
        if not existe:
            db.add(Medicamento(nombre=nombre))
            print(f"Insertado medicamento: {nombre}")
    db.commit()
    db.close()
    print("Seed de medicamentos completado.")

if __name__ == "__main__":
    seed_medicamentos()
