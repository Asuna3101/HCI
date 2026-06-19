from sqlalchemy import text
from app.core.database import engine

def migrate_comidas_usuario():
    """Agrega la columna descripcion a la tabla comidas_usuario si no existe"""
    with engine.connect() as conn:
        # Verificar si la columna ya existe
        check_column = text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='comidas_usuario' 
            AND column_name='descripcion';
        """)
        result = conn.execute(check_column)
        exists = result.fetchone()
        
        if not exists:
            # Agregar la columna
            alter_table = text("""
                ALTER TABLE comidas_usuario 
                ADD COLUMN descripcion VARCHAR(500);
            """)
            conn.execute(alter_table)
            conn.commit()
            print("OK: Columna 'descripcion' agregada a la tabla 'comidas_usuario'")
        else:
            print("ℹ️  La columna 'descripcion' ya existe en 'comidas_usuario'")

if __name__ == "__main__":
    migrate_comidas_usuario()
