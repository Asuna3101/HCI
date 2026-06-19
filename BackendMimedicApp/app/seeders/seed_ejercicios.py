"""
Seeder para ejercicios (catálogo)
"""
from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.ejercicio import Ejercicio

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def seed_ejercicios():
    db = SessionLocal()
    ejercicios = [
        "Correr",
        "Caminar",
        "Natación",
        "Yoga",
        "Pesas",
        "Ciclismo",
        "Pilates",
        "Zumba",
        "Spinning",
        "CrossFit",
        "Boxeo",
        "Estiramientos",
        "Calistenia",
        "Bailar",
        "Escalada",
    ]
    for nombre in ejercicios:
        existe = db.query(Ejercicio).filter(Ejercicio.nombre == nombre).first()
        if not existe:
            db.add(Ejercicio(nombre=nombre))
            print(f"✅ Insertado ejercicio: {nombre}")
    db.commit()
    db.close()
    print("💪 Seed de ejercicios completado.")

if __name__ == "__main__":
    seed_ejercicios()
