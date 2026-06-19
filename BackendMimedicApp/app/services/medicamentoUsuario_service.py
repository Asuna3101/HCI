"""
Servicio para registrar medicamentos asociados a usuarios
"""
from app.interfaces.medicamento_repository_interface import IMedicamentoRepository
from app.interfaces.medicamento_usuario_repository_interface import IMedicamentoUsuarioRepository
from app.interfaces.medicamento_usuario_service_interface import IMedicamentoUsuarioService
from app.interfaces.unidad_repository_interface import IUnidadRepository


class MedicamentoUsuarioService(IMedicamentoUsuarioService):
    def __init__(
        self,
        med_repo: IMedicamentoRepository,
        unidad_repo: IUnidadRepository,
        medxuser_repo: IMedicamentoUsuarioRepository,
    ):
        self.med_repo = med_repo
        self.unidad_repo = unidad_repo
        self.medxuser_repo = medxuser_repo

    def registrar_medicamento_usuario(self, id_usuario: int, data):
        # 1) Catálogos
        medicamento = self.med_repo.get_or_create_medicamento(data.nombre)
        
        # Validar que no exista el mismo medicamento activo
        if self.medxuser_repo.existe_medicamento_activo(id_usuario, medicamento.id):
            raise ValueError(f"Ya tienes el medicamento '{data.nombre}' registrado y activo")
        
        unidad = self.unidad_repo.get_or_create_unidad(data.unidad)

        # Basic validation: fecha_fin must be >= fecha_inicio and frecuencia > 0
        try:
            fecha_inicio = data.fecha_inicio
            fecha_fin = data.fecha_fin
        except Exception:
            raise ValueError("Fechas inválidas")

        if fecha_fin < fecha_inicio:
            raise ValueError("fecha_fin debe ser posterior o igual a fecha_inicio")

        try:
            frecuencia = float(data.frecuencia_horas)
        except Exception:
            frecuencia = 0

        if frecuencia <= 0:
            raise ValueError("frecuencia_horas debe ser un número mayor que 0")

        # 2) Asociación user-medicamento
        medxuser_data = {
            "idUsuario": id_usuario,
            "idMedicamento": medicamento.id,
            "idUnidad": unidad.id,
            "dosis": data.dosis,
            "frecuencia_horas": data.frecuencia_horas,
            "fecha_inicio": data.fecha_inicio,
            "fecha_fin": data.fecha_fin,
        }
        medxuser = self.medxuser_repo.create(medxuser_data)

        # 3) Generar tomas
        self.medxuser_repo.generate_tomas(medxuser)

        return {
            "id": medicamento.id,
            "nombre": medicamento.nombre,
            "message": "Medicamento guardado correctamente",
        }

    def obtener_medicamentos_por_usuario(self, id_usuario: int):
        rows = self.medxuser_repo.get_by_usuario(id_usuario)
        result = [
            {
                "id": mxu.id,
                "nombre": med.nombre,
                "dosis": mxu.dosis,
                "unidad": un.nombre,
                "frecuenciaHoras": mxu.frecuencia_horas,
                "fechaInicio": mxu.fecha_inicio,
                "fechaFin": mxu.fecha_fin,
            }
            for mxu, med, un in rows
        ]
        return result

    def actualizar_medicamento_usuario(self, id_usuario: int, id_medicamento_usuario: int, data):
        """Actualizar un registro medicamento-usuario.

        Esta función actualiza campos permitidos del registro. No regenera automáticamente
        las tomas asociadas (para eso se debería usar el servicio de tomas o exponer
        métodos adicionales en el repositorio).
        """
        # 1) Validar existencia del registro
        medxuser = self.medxuser_repo.get_by_id(id_medicamento_usuario)
        if not medxuser or medxuser.idUsuario != id_usuario:
            raise ValueError("Registro de medicamento por usuario no encontrado")

        update_data = {}

        # Si cambia el nombre del medicamento, obtener/crear
        if hasattr(data, "nombre") and data.nombre:
            medicamento = self.med_repo.get_or_create_medicamento(data.nombre)
            update_data["idMedicamento"] = medicamento.id

        # Si cambia la unidad
        if hasattr(data, "unidad") and data.unidad:
            unidad = self.unidad_repo.get_or_create_unidad(data.unidad)
            update_data["idUnidad"] = unidad.id

        # Campos directos
        for campo in ("dosis", "frecuencia_horas", "fecha_inicio", "fecha_fin"):
            if hasattr(data, campo):
                update_data[campo] = getattr(data, campo)

        if not update_data:
            return {"message": "No hay cambios"}

        actualizado = self.medxuser_repo.update(id_medicamento_usuario, update_data)
        if not actualizado:
            raise ValueError("No se pudo actualizar el registro")

        return {
            "id": actualizado.id,
            "message": "Medicamento de usuario actualizado correctamente",
        }

    def eliminar_medicamento_usuario(self, id_usuario: int, id_medicamento_usuario: int) -> bool:
        """Eliminar un registro medicamento-usuario si pertenece al usuario.

        Llama al repositorio para realizar la eliminación y devuelve True/False.
        Lanza ValueError si el registro no existe o no pertenece al usuario.
        """
        eliminado = self.medxuser_repo.delete(id_usuario, id_medicamento_usuario)
        if not eliminado:
            raise ValueError("No se pudo eliminar el registro (no existe o no pertenece al usuario)")
        return True

    def eliminar_lista_medicamento_usuario(self, id_usuario: int, ids: list) -> dict:
        """Eliminar una lista de registros medicamento-usuario por sus IDs.

        Devuelve un resumen con los ids eliminados y los que fallaron.
        """
        deleted_ids = []
        failed_ids = []

        for mid in ids:
            try:
                ok = self.medxuser_repo.delete(id_usuario, mid)
                if ok:
                    deleted_ids.append(mid)
                else:
                    failed_ids.append(mid)
            except Exception:
                failed_ids.append(mid)

        return {
            "deleted_count": len(deleted_ids),
            "deleted_ids": deleted_ids,
            "failed_ids": failed_ids,
        }