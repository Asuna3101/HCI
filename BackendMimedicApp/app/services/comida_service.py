"""
Servicio para lógica de alimentos
"""
from app.interfaces.comida_service_interface import IComidaService
from app.interfaces.comida_repository_interface import IComidaRepository
from app.models.comidas import Alimento


class ComidaService(IComidaService):
    def __init__(self, repo: IComidaRepository):
        self.repo = repo

    def listar_todas(self, skip: int = 0, limit: int = 100) -> list[Alimento]:
        return self.repo.get_all(skip=skip, limit=limit)

    def buscar_por_nombre(self, query: str, limit: int = 20) -> list[Alimento]:
        """Busca comidas por nombre (autocompletado)"""
        if not query or len(query.strip()) == 0:
            return []
        return self.repo.search_by_nombre(query.strip(), limit=limit)

    def obtener_o_crear(self, nombre: str, detalles: str | None = None) -> Alimento:
        return self.repo.get_or_create_alimento(nombre, detalles)

    def obtener_por_id(self, id: int) -> Alimento | None:
        return self.repo.get_by_id(id)

    def listar_por_recomendable(self, recomendable: int, skip: int = 0, limit: int = 100) -> list[Alimento]:
        # Deprecated for normalized schema: recomendable is per-user in comidas_usuario
        return []

    def crear(self, nombre: str, detalles: str | None = None) -> Alimento:
        return self.repo.create(nombre, detalles)

    def actualizar(self, id: int, **kwargs) -> Alimento | None:
        return self.repo.update(id, **kwargs)

    def eliminar(self, id: int) -> bool:
        return self.repo.delete(id)
