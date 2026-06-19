"""
Repositorio para EjercicioUsuario
"""
from sqlalchemy import desc
from sqlalchemy.orm import Session
from app.models.ejercicio import Ejercicio
from app.models.ejercicioUsuario import EjercicioUsuario
from app.interfaces.ejercicio_usuario_repository_interface import IEjercicioUsuarioRepository
from datetime import time, timedelta, datetime, date


class EjercicioUsuarioRepository(IEjercicioUsuarioRepository):

    def __init__(self, db: Session):
        self.db = db

    def create(self, data: dict) -> EjercicioUsuario:
        ejxuser = EjercicioUsuario(**data)
        self.db.add(ejxuser)
        self.db.commit()
        self.db.refresh(ejxuser)
        return ejxuser

    def get_by_usuario(self, id_usuario: int):
        return (
            self.db.query(EjercicioUsuario, Ejercicio)
            .join(Ejercicio, Ejercicio.id == EjercicioUsuario.idEjercicio)
            .filter(EjercicioUsuario.idUsuario == id_usuario)
            .order_by(desc(EjercicioUsuario.createdAt))
            .all()
        )

    def get_by_id(self, ejxuser_id: int) -> EjercicioUsuario:
        return (
            self.db.query(EjercicioUsuario)
            .filter(EjercicioUsuario.id == ejxuser_id)
            .first()
        )

    def update(self, ejxuser_id: int, data: dict) -> EjercicioUsuario:
        ejxuser = (
            self.db.query(EjercicioUsuario)
            .filter(EjercicioUsuario.id == ejxuser_id)
            .first()
        )
        if not ejxuser:
            return None

        for field, value in data.items():
            setattr(ejxuser, field, value)

        self.db.commit()
        self.db.refresh(ejxuser)
        return ejxuser

    def delete(self, id_usuario: int, ejxuser_ids: list[int]) -> bool:
        deleted_count = (
            self.db.query(EjercicioUsuario)
            .filter(
                EjercicioUsuario.id.in_(ejxuser_ids),
                EjercicioUsuario.idUsuario == id_usuario
            )
            .delete(synchronize_session=False)
        )
        
        self.db.commit()
        return deleted_count > 0

    def check_horario_conflict(self, id_usuario: int, horario: time, duracion_min: int, exclude_id: int = None) -> bool:
        hoy = datetime.today().date()
        inicio = datetime.combine(hoy, horario)
        fin = inicio + timedelta(minutes=duracion_min)
        
        query = (
            self.db.query(EjercicioUsuario)
            .filter(EjercicioUsuario.idUsuario == id_usuario)
        )
        
        # Excluir el ejercicio actual si es un update
        if exclude_id:
            query = query.filter(EjercicioUsuario.id != exclude_id)
        
        ejercicios_existentes = query.all()
        
        # Verificar conflictos con cada ejercicio existente
        for ej in ejercicios_existentes:
            if ej.horario and ej.duracion_min:
                ej_inicio = datetime.combine(hoy, ej.horario)
                ej_fin = ej_inicio + timedelta(minutes=ej.duracion_min)
                
                # Verificar solapamiento
                if (inicio < ej_fin) and (fin > ej_inicio):
                    return True
        
        return False

    def reset_realizados_diarios(self, id_usuario: int) -> bool:
        hoy = date.today()
        
        # Solo resetear ejercicios que NO fueron reseteados hoy
        updated = (
            self.db.query(EjercicioUsuario)
            .filter(
                EjercicioUsuario.idUsuario == id_usuario,
                (EjercicioUsuario.ultimo_realizado < hoy) | (EjercicioUsuario.ultimo_realizado == None)
            )
            .update(
                {
                    "realizado": False,
                    "ultimo_realizado": hoy
                },
                synchronize_session=False
            )
        )
        
        if updated > 0:
            self.db.commit()
            return True
        
        return False