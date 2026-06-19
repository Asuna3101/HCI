"""  
Servicio para la lógica de comidas_usuario
"""
from sqlalchemy.orm import joinedload
from app.repositories.comidas_usuario_repo import ComidaUsuarioRepository
from app.models.comidas_usuario import ComidaUsuario


class ComidasUsuarioService:
    def __init__(self, repo: ComidaUsuarioRepository):
        self.repo = repo

    def create_for_user(self, comida_id: int, usuario_id: int, categoria_id: int | None = None, descripcion: str | None = None) -> ComidaUsuario:
        return self.repo.create(comida_id, usuario_id, categoria_id, descripcion)

    def list_for_user(self, usuario_id: int):
        """Retorna las comidas del usuario con relaciones cargadas"""
        return self.repo.get_by_user_with_relations(usuario_id)

    def update(self, id: int, update_data: dict) -> ComidaUsuario | None:
        """Actualiza una comida de usuario"""
        return self.repo.update(id, update_data)

    def delete(self, id: int) -> bool:
        return self.repo.delete(id)
    
    def delete_multiple(self, ids: list[int]) -> bool:
        """Elimina múltiples registros de comidas_usuario"""
        return self.repo.delete_multiple(ids)