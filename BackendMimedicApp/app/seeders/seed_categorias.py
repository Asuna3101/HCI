from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.categoria import Categoria

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def seed_categorias():
    db = SessionLocal()
    categorias = [
        ("Recomendable",),
        ("No recomendable",),
    ]
    for (nombre,) in categorias:
        existe = db.query(Categoria).filter(Categoria.nombre == nombre).first()
        if not existe:
            db.add(Categoria(nombre=nombre))
            print(f"Insertada categoria: {nombre}")
    db.commit()
    db.close()
    print("Seed de categorias completado.")


if __name__ == "__main__":
    seed_categorias()
