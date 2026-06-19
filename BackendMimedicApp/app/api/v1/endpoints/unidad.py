from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.controllers.unidad_controller import UnidadController

router = APIRouter()

@router.get("/")
def listar_unidades(db: Session = Depends(get_db)):
    controller = UnidadController(db)
    return controller.listar_todas()
