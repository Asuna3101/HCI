from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.comidas import Alimento

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def seed_comidas():
    db = SessionLocal()
    comidas = [
        "Manzana",
        "Plátano",
        "Naranja",
        "Papas fritas",
        "Ensalada verde",
        "Pollo a la plancha",
        "Arroz integral",
        "Pasta",
        "Refresco azucarado",
        "Agua",
        "Jugo natural",
        "Pizza",
        "Hamburguesa",
        "Ensalada de frutas",
        "Yogurt",
    ]
    for nombre in comidas:
        existe = db.query(Alimento).filter(Alimento.nombre == nombre).first()
        if not existe:
            db.add(Alimento(nombre=nombre))
            print(f"Insertado alimento: {nombre}")
    db.commit()
    db.close()
    print("Seed de comidas completado.")


if __name__ == "__main__":
    seed_comidas()
