"""
Endpoint para ejercicio / ejercicioUsuario
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.api.v1.endpoints.dependencies import get_current_user
from app.controllers.ejercicioUsuario_controller import EjercicioUsuarioController
from app.controllers.ejercicio_controller import EjercicioController
from app.core.database import get_db
from app.schemas.ejercicio import EjercicioResponse
from app.schemas.ejercicioUsuario import EjercicioUsuarioCreate, EjercicioUsuarioDeleteMultiple, EjercicioUsuarioResponse, EjercicioUsuarioUpdate

router = APIRouter()

@router.get("/", response_model=list[EjercicioResponse])
def listar_ejercicios(db: Session = Depends(get_db)):
    controller = EjercicioController(db)
    return controller.listar_todos()

@router.post("/usuario", response_model=EjercicioUsuarioResponse)
def registrar_ejercicio_usuario(
    data: EjercicioUsuarioCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    controller = EjercicioUsuarioController(db)
    return controller.registrar(user.id, data)

@router.get("/usuario", response_model=list[EjercicioUsuarioResponse])
def listar_ejercicios_usuario(
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    controller = EjercicioUsuarioController(db)
    return controller.listar(user.id)

@router.put("/usuario/{id}", response_model=EjercicioUsuarioResponse)
def actualizar_ejercicio_usuario(
    id: int,
    data: EjercicioUsuarioUpdate,
    db: Session = Depends(get_db),
):
    controller = EjercicioUsuarioController(db)
    return controller.actualizar(id, data)

@router.delete("/usuario")
def eliminar_ejercicios_multiple(
    data: EjercicioUsuarioDeleteMultiple,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    controller = EjercicioUsuarioController(db)
    return controller.eliminar(user.id, data.ids)


