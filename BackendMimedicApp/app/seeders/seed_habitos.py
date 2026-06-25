from sqlalchemy.orm import sessionmaker
from app.core.database import engine
from app.models.habito import Habito, Logro

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

HABITOS = [
    {"id": 1, "nombre": "Agua", "descripcion": "Toma 8 vasos de agua", "icono": "water_drop", "puntos_por_completar": 10},
    {"id": 2, "nombre": "Sueño", "descripcion": "Duerme 8 horas", "icono": "bedtime", "puntos_por_completar": 10},
    {"id": 3, "nombre": "Ejercicio", "descripcion": "30 min de actividad física", "icono": "fitness_center", "puntos_por_completar": 10},
    {"id": 4, "nombre": "Lectura", "descripcion": "Lee 30 minutos", "icono": "menu_book", "puntos_por_completar": 10},
    {"id": 5, "nombre": "Meditación", "descripcion": "Medita 10 minutos", "icono": "self_improvement", "puntos_por_completar": 10},
]

LOGROS = [
    {"id": 1, "nombre": "¡Primer Paso!", "descripcion": "Completa tu primer hábito del día", "criterio": "completar_1_habito"},
    {"id": 2, "nombre": "Día Perfecto", "descripcion": "Completa todos los hábitos en un mismo día", "criterio": "todos_habitos_dia"},
    {"id": 3, "nombre": "Racha de 3", "descripcion": "Mantén una racha de 3 días consecutivos", "criterio": "racha_3"},
    {"id": 4, "nombre": "Semana Activa", "descripcion": "Completa al menos un hábito por 7 días seguidos", "criterio": "racha_7"},
    {"id": 5, "nombre": "Experto en Hábitos", "descripcion": "Alcanza el nivel Experto (1000 puntos)", "criterio": "nivel_5"},
]


def seed_habitos():
    db = SessionLocal()
    try:
        for data in HABITOS:
            if not db.query(Habito).filter(Habito.id == data["id"]).first():
                db.add(Habito(**data))
                print(f"[OK] Habito insertado: {data['nombre']}")

        for data in LOGROS:
            if not db.query(Logro).filter(Logro.id == data["id"]).first():
                db.add(Logro(**data))
                print(f"[OK] Logro insertado: {data['nombre']}")

        db.commit()
        print("[OK] Seed de habitos y logros completado.")
    finally:
        db.close()


if __name__ == "__main__":
    seed_habitos()
