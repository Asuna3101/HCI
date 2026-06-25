from app.seeders.seed_unidades import seed_unidades
from app.seeders.seed_medicamentos import seed_medicamentos
from app.seeders.seed_healtcare import seed_healthcare
from app.seeders.seed_comidas import seed_comidas
from app.seeders.seed_categorias import seed_categorias
from app.seeders.seed_ejercicios import seed_ejercicios
from app.seeders.migrate_comidas_usuario import migrate_comidas_usuario
from app.seeders.seed_habitos import seed_habitos


def run_all_seeders():
    print("Ejecutando seeders...")
    tasks = [
        ("migrar_comidas_usuario", migrate_comidas_usuario),
        ("healthcare", lambda: seed_healthcare(drop=False)),
        ("unidades", seed_unidades),
        ("medicamentos", seed_medicamentos),
        ("categorias", seed_categorias),
        ("comidas", seed_comidas),
        ("ejercicios", seed_ejercicios),
        ("habitos", seed_habitos),
    ]
    for name, fn in tasks:
        try:
            fn()
        except Exception as e:
            print(f"[ERROR] Seeder '{name}' fallo: {e}")
    print("Seeders ejecutados (revisa errores anteriores si los hubo).")

if __name__ == "__main__":
    run_all_seeders()
