"""
Endpoint para registrar medicamentos 
"""
from fastapi import APIRouter, Depends, Body
from sqlalchemy.orm import Session
from app.controllers.medicamento_controller import MedicamentoController
from app.core.database import get_db
from app.controllers.medicamentoUsuario_controller import MedicamentoUsuarioController
from app.api.v1.endpoints.dependencies import get_current_user 
from app.schemas.medicamentoUsuario import (
    MedicamentoUsuarioCreate,
)

router = APIRouter()

@router.get("/")
def listar_medicamentos(db: Session = Depends(get_db)):
    controller = MedicamentoController(db)
    return controller.listar_todos()

@router.post("/usuario/registrar")
def registrar_medicamento_usuario(
    data: MedicamentoUsuarioCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user), 
):
    controller = MedicamentoUsuarioController(db)
    return controller.registrar_medicamento_usuario(user.id, data)

@router.get("/usuario/lista")
def listar_mis_medicamentos(
    db: Session = Depends(get_db),
    user = Depends(get_current_user) 
):
    controller = MedicamentoUsuarioController(db)
    return controller.obtener_medicamentos_usuario(user.id)


@router.put("/usuario/actualizar/{id_medicamento_usuario}")
def actualizar_medicamento_usuario(
    id_medicamento_usuario: int,
    data: MedicamentoUsuarioCreate,
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    """Actualizar un medicamento asociado al usuario autenticado.
    """
    controller = MedicamentoUsuarioController(db)
    return controller.actualizar_medicamento_usuario(user.id, id_medicamento_usuario, data)


@router.delete("/usuario/eliminar/{id_medicamento_usuario}")
def eliminar_medicamento_usuario(
    id_medicamento_usuario: int,
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    """Eliminar un medicamento asociado al usuario autenticado."""
    controller = MedicamentoUsuarioController(db)
    return controller.eliminar_medicamento_usuario(user.id, id_medicamento_usuario)


@router.post("/usuario/eliminar-lista")
def eliminar_lista_medicamento_usuario(
    ids: list[int] = Body(..., embed=True),
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    """Eliminar múltiples medicamentos asociados al usuario autenticado.
    """
    controller = MedicamentoUsuarioController(db)
    return controller.eliminar_lista_medicamento_usuario(user.id, ids)
