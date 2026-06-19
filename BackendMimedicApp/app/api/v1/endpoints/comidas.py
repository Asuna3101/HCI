"""
Endpoints para comidas (catálogo) y comidas de usuario
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.controllers.comida_controller import ComidaController
from app.controllers.comidas_usuario_controller import ComidaUsuarioController
from app.schemas.comida import (
    ComidaOut, 
    ComidaCreate, 
    ComidaUsuarioCreate,
    ComidaUsuarioUpdate,
    ComidaUsuarioResponse,
    ComidaUsuarioDeleteMultiple
)
from app.api.v1.endpoints.dependencies import get_current_user

router = APIRouter()


# ==================== CATÁLOGO DE COMIDAS ====================

@router.get("/", response_model=list[ComidaOut])
def listar_comidas_catalogo(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    """Lista todas las comidas del catálogo global"""
    controller = ComidaController(db)
    return controller.listar_todas(skip=skip, limit=limit)


@router.get("/buscar/", response_model=list[ComidaOut])
def buscar_comidas_catalogo(
    q: str,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """Busca comidas en el catálogo por nombre (autocompletado)"""
    controller = ComidaController(db)
    return controller.buscar_por_nombre(q, limit=limit)


# ==================== COMIDAS DE USUARIO ====================

@router.post("/usuario", response_model=ComidaUsuarioResponse, status_code=status.HTTP_201_CREATED)
def registrar_comida_usuario(
    data: ComidaUsuarioCreate,
    db: Session = Depends(get_db),
    user = Depends(get_current_user),
):
    """
    Registra una comida para el usuario autenticado.
    - Si la comida no existe en el catálogo, se crea automáticamente.
    - Se asocia al usuario con la categoría especificada (Recomendable/No Recomendable).
    """
    controller = ComidaUsuarioController(db)
    cu = controller.registrar(user.id, data)
    
    # Construir respuesta con datos completos
    return ComidaUsuarioResponse(
        id=cu.id,
        comida_id=cu.comida_id,
        usuario_id=cu.usuario_id,
        categoria_id=cu.categoria_id,
        nombre=cu.comida.nombre,
        detalles=None,
        descripcion=cu.descripcion,
        categoria_nombre=cu.categoria.nombre if cu.categoria else None,
        createdAt=cu.createdAt
    )


@router.get("/usuario", response_model=list[ComidaUsuarioResponse])
def listar_comidas_usuario(
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    """Lista todas las comidas del usuario autenticado con sus categorías"""
    controller = ComidaUsuarioController(db)
    comidas = controller.listar(user.id)
    
    # Transformar a respuesta con datos completos
    return [
        ComidaUsuarioResponse(
            id=cu.id,
            comida_id=cu.comida_id,
            usuario_id=cu.usuario_id,
            categoria_id=cu.categoria_id,
            nombre=cu.comida.nombre,
            detalles=None,
            descripcion=cu.descripcion,
            categoria_nombre=cu.categoria.nombre if cu.categoria else None,
            createdAt=cu.createdAt
        )
        for cu in comidas
    ]


@router.put("/usuario/{id}", response_model=ComidaUsuarioResponse)
def actualizar_comida_usuario(
    id: int,
    data: ComidaUsuarioUpdate,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    """Actualiza una comida del usuario (descripción y/o categoría)"""
    controller = ComidaUsuarioController(db)
    cu = controller.actualizar(id, user.id, data)
    
    return ComidaUsuarioResponse(
        id=cu.id,
        comida_id=cu.comida_id,
        usuario_id=cu.usuario_id,
        categoria_id=cu.categoria_id,
        nombre=cu.comida.nombre,
        detalles=None,
        descripcion=cu.descripcion,
        categoria_nombre=cu.categoria.nombre if cu.categoria else None,
        createdAt=cu.createdAt
    )


@router.delete("/usuario")
def eliminar_comidas_multiple(
    data: ComidaUsuarioDeleteMultiple,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    """Elimina múltiples comidas del usuario"""
    controller = ComidaUsuarioController(db)
    return controller.eliminar(user.id, data.ids)


# ==================== CATÁLOGO - RUTAS CON PARÁMETROS ====================

@router.get("/{id}", response_model=ComidaOut)
def obtener_comida_catalogo(id: int, db: Session = Depends(get_db)):
    """Obtiene una comida específica del catálogo"""
    controller = ComidaController(db)
    return controller.obtener_por_id(id)
