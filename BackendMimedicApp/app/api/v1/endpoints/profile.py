from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from app.core.database import get_db
from app.api.v1.endpoints.dependencies import get_current_user
from app.controllers.profile_controller import ProfileController
from pydantic import BaseModel


class ChangePasswordBody(BaseModel):
    old_password: str
    new_password: str


class DeleteAccountBody(BaseModel):
    confirm: bool = False

router = APIRouter()

def _update_photo_impl(
    file: Optional[UploadFile],
    db: Session,
    current_user,
):
    ctl = ProfileController(db)
    if not file:
        raise HTTPException(status_code=400, detail="Se requiere un archivo de imagen")
    file_bytes = ctl.service.save_upload(file.filename, file.file)
    photo_b64 = ctl.update_photo(current_user.id, file_bytes, file.content_type)
    return {"photo": photo_b64, "content_type": file.content_type}


@router.put("/me/photo", status_code=status.HTTP_200_OK)
async def update_photo_put(
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return _update_photo_impl(file, db, current_user)


@router.post("/me/photo", status_code=status.HTTP_200_OK)
async def update_photo_post(
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    return _update_photo_impl(file, db, current_user)


@router.put("/me/password", status_code=status.HTTP_200_OK)
async def change_password(
    body: ChangePasswordBody,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ctl = ProfileController(db)
    ctl.change_password(current_user.id, body.old_password, body.new_password)
    return {"message": "Password updated"}


@router.delete("/me", status_code=status.HTTP_200_OK)
async def delete_account(
    body: DeleteAccountBody | None = None,
    confirm: bool = Query(False),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    ctl = ProfileController(db)
    confirm_flag = confirm or (body.confirm if body else False)
    ctl.delete_account(current_user.id, confirm_flag)
    return {"message": "Cuenta desactivada"}


@router.post("/recover", status_code=status.HTTP_200_OK)
async def recover_account(
    email: str,
    db: Session = Depends(get_db),
):
    ctl = ProfileController(db)
    ctl.recover_account(email)
    return {"message": "Si el email existe, se enviarán instrucciones"}
