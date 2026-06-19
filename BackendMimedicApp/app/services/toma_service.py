"""
Servicio para gestión de tomas 
"""
from app.interfaces.toma_repository_interface import ITomaRepository
from app.interfaces.toma_service_interface import ITomaService


class TomaService(ITomaService):
    def __init__(self, toma_repo: ITomaRepository):
        self.toma_repo = toma_repo

    def marcar_toma(self, toma_id: int, tomado: bool):
        toma = self.toma_repo.update_tomado(toma_id, tomado)
        if not toma:
            raise ValueError("Toma no encontrada")

        # Si todas las tomas de ese medxuser están en True, limpiar
        pendientes = self.toma_repo.count_pendientes_by_medxuser(toma.idMedxUser)
        if pendientes == 0:
            self.toma_repo.delete_all_by_medxuser(toma.idMedxUser)

        return toma

    def postpone_tomas(self, toma_id: int, minutes: int) -> int:
        """Postpone la toma y las siguientes del mismo medicamento-usuario.
        Retorna el número de tomas actualizadas."""
        updated = self.toma_repo.postpone_from(toma_id, minutes)
        if updated == 0:
            raise ValueError("Toma no encontrada o no hay tomas a posponer")
        return updated
