from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.controllers.categoria_controller import CategoriaController
from app.schemas.categoria import CategoriaOut, CategoriaCreate

router = APIRouter()


@router.get("/", response_model=list[CategoriaOut])
def listar_categorias(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    controller = CategoriaController(db)
    return controller.listar_todas(skip=skip, limit=limit)


@router.get("/{id}", response_model=CategoriaOut)
def obtener_categoria(id: int, db: Session = Depends(get_db)):
    controller = CategoriaController(db)
    return controller.obtener_por_id(id)


@router.post("/", response_model=CategoriaOut, status_code=status.HTTP_201_CREATED)
def crear_categoria(payload: CategoriaCreate, db: Session = Depends(get_db)):
    controller = CategoriaController(db)
    return controller.crear(payload.nombre)


@router.put("/{id}", response_model=CategoriaOut)
def actualizar_categoria(id: int, payload: CategoriaCreate, db: Session = Depends(get_db)):
    controller = CategoriaController(db)
    return controller.actualizar(id, payload.nombre)


@router.delete("/{id}")
def eliminar_categoria(id: int, db: Session = Depends(get_db)):
    controller = CategoriaController(db)
    return controller.eliminar(id)
