"""
Repositorio para la tabla comidas_usuario
"""
from sqlalchemy.orm import Session, joinedload
from app.models.comidas_usuario import ComidaUsuario


class ComidaUsuarioRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, comida_id: int, usuario_id: int, categoria_id: int | None = None, descripcion: str | None = None) -> ComidaUsuario:
        cu = ComidaUsuario(
            comida_id=comida_id, 
            usuario_id=usuario_id, 
            categoria_id=categoria_id,
            descripcion=descripcion
        )
        self.db.add(cu)
        self.db.commit()
        self.db.refresh(cu)
        return cu

    def get_by_user(self, usuario_id: int):
        return (
            self.db.query(ComidaUsuario)
            .filter(ComidaUsuario.usuario_id == usuario_id)
            .all()
        )
    
    def get_by_user_with_relations(self, usuario_id: int):
        """Obtiene comidas del usuario con relaciones cargadas (comida, categoria)"""
        return (
            self.db.query(ComidaUsuario)
            .options(joinedload(ComidaUsuario.comida))
            .options(joinedload(ComidaUsuario.categoria))
            .filter(ComidaUsuario.usuario_id == usuario_id)
            .all()
        )

    def update(self, id: int, update_data: dict) -> ComidaUsuario | None:
        """Actualiza un registro de comida_usuario"""
        cu = self.db.query(ComidaUsuario).filter(ComidaUsuario.id == id).first()
        if not cu:
            return None
        
        for key, value in update_data.items():
            if hasattr(cu, key) and value is not None:
                setattr(cu, key, value)
        
        self.db.commit()
        self.db.refresh(cu)
        return cu

    def delete(self, id: int) -> bool:
        cu = self.db.query(ComidaUsuario).filter(ComidaUsuario.id == id).first()
        if not cu:
            return False
        self.db.delete(cu)
        self.db.commit()
        return True
    
    def delete_multiple(self, ids: list[int]) -> bool:
        """Elimina múltiples registros por ID"""
        if not ids:
            return False
        
        deleted = self.db.query(ComidaUsuario).filter(ComidaUsuario.id.in_(ids)).delete(synchronize_session=False)
        self.db.commit()
        return deleted > 0
