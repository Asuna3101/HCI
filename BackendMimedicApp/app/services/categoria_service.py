from app.interfaces.categoria_service_interface import ICategoriaService
from app.interfaces.categoria_repository_interface import ICategoriaRepository
from app.models.categoria import Categoria


class CategoriaService(ICategoriaService):
    def __init__(self, repo: ICategoriaRepository):
        self.repo = repo

    def listar_todas(self, skip: int = 0, limit: int = 100) -> list[Categoria]:
        return self.repo.get_all(skip=skip, limit=limit)

    def obtener_por_id(self, id: int) -> Categoria | None:
        return self.repo.get_by_id(id)

    def crear(self, nombre: str) -> Categoria:
        return self.repo.create(nombre)

    def actualizar(self, id: int, nombre: str) -> Categoria | None:
        return self.repo.update(id, nombre)

    def eliminar(self, id: int) -> bool:
        return self.repo.delete(id)
