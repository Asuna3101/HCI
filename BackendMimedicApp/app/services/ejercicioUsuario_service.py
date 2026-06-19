"""
Servicio para registrar ejercicios asociados a un usuario
"""
from app.interfaces.ejercicio_repository_interface import IEjercicioRepository
from app.interfaces.ejercicio_usuario_repository_interface import IEjercicioUsuarioRepository
from app.interfaces.ejercicio_usuario_service_interface import IEjercicioUsuarioService


class EjercicioUsuarioService(IEjercicioUsuarioService):

    def __init__(
        self, 
        ejxuser_repo: IEjercicioUsuarioRepository,
        ejercicio_repo: IEjercicioRepository
    ):
        self.ejxuser_repo = ejxuser_repo
        self.ejercicio_repo = ejercicio_repo

    def registrar_ejercicio_usuario(self, id_usuario: int, data):
        ejercicio = self.ejercicio_repo.get_or_create_ejercicio(data.nombre)

        # Validaciones básicas
        if not data.nombre.strip():
            raise ValueError("El nombre del ejercicio es obligatorio")
        
        # Validar conflicto de horarios
        if self.ejxuser_repo.check_horario_conflict(id_usuario, data.horario, data.duracion_min):
            raise ValueError("Ya tienes un ejercicio programado en ese horario")
        
        # Crear data final
        ejxuser_data = {
            "idUsuario": id_usuario,
            "idEjercicio": ejercicio.id,      
            "notas": data.notas,
            "horario": data.horario,
            "duracion_min": data.duracion_min,
            "realizado": data.realizado,
        }

        ejxuser = self.ejxuser_repo.create(ejxuser_data)

        return {
            "id": ejxuser.id,
            "nombre": ejercicio.nombre,
            "notas": ejxuser.notas,
            "horario": ejxuser.horario,
            "duracion_min": ejxuser.duracion_min,
            "realizado": ejxuser.realizado
        }

    def obtener_ejercicios_usuario(self, id_usuario: int):
        self.ejxuser_repo.reset_realizados_diarios(id_usuario)
        
        rows = self.ejxuser_repo.get_by_usuario(id_usuario)

        return [
            {
                "id": exu.id,
                "nombre": e.nombre,
                "notas": exu.notas,
                "horario": exu.horario,
                "duracion_min": exu.duracion_min,
                "realizado": exu.realizado,
            }
            for exu, e in rows
        ]

    def actualizar_ejercicio_usuario(self, ejxuser_id: int, data):
        update_data = data.model_dump(exclude_unset=True)
        
        if "nombre" in update_data:
            ejercicio = self.ejercicio_repo.get_or_create_ejercicio(update_data.pop("nombre"))
            update_data["idEjercicio"] = ejercicio.id
        
        # Validar conflicto de horarios si se actualiza horario o duración
        if "horario" in update_data or "duracion_min" in update_data:
            # Obtener el ejercicio actual
            ejxuser_actual = self.ejxuser_repo.get_by_id(ejxuser_id)
            if not ejxuser_actual:
                return None
            
            # Usar valores nuevos o actuales
            horario = update_data.get("horario", ejxuser_actual.horario)
            duracion_min = update_data.get("duracion_min", ejxuser_actual.duracion_min)
            
            # Verificar conflicto (excluyendo el ejercicio actual)
            if self.ejxuser_repo.check_horario_conflict(
                ejxuser_actual.idUsuario, 
                horario, 
                duracion_min, 
                exclude_id=ejxuser_id
            ):
                raise ValueError("Ya tienes un ejercicio programado en ese horario")
        
        ejxuser = self.ejxuser_repo.update(ejxuser_id, update_data)
        if not ejxuser:
            return None
        
        # Obtener el ejercicio relacionado para el nombre
        ejercicio = self.ejercicio_repo.get_by_id(ejxuser.idEjercicio)
        
        return {
            "id": ejxuser.id,
            "nombre": ejercicio.nombre,
            "notas": ejxuser.notas,
            "horario": ejxuser.horario,
            "duracion_min": ejxuser.duracion_min,
            "realizado": ejxuser.realizado
        }

    def eliminar_ejercicios_usuario(self, id_usuario: int, ejercicio_ids: list[int]) -> bool:
        if not ejercicio_ids:
            raise ValueError("Debe proporcionar al menos un ID para eliminar")
        
        eliminado = self.ejxuser_repo.delete(id_usuario, ejercicio_ids)
        
        if not eliminado:
            raise ValueError("No se encontraron ejercicios para eliminar (no existen o no pertenecen al usuario)")
        
        return True