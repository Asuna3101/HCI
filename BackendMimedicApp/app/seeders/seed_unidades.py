from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.unidad import Unidad

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def seed_unidades():
    db = SessionLocal()
    unidades = ["mg", "ml", "gotas", "pastillas"]
    for nombre in unidades:
        existe = db.query(Unidad).filter(Unidad.nombre == nombre).first()
        if not existe:
            db.add(Unidad(nombre=nombre))
            print(f"✅ Insertada unidad: {nombre}")
    db.commit()
    db.close()
    print("⚗️ Seed de unidades completado.")

if __name__ == "__main__":
    seed_unidades()
