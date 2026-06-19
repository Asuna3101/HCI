from fastapi import HTTPException
from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory
from app.interfaces.profile_service_interface import IProfileService


class ProfileController:
    def __init__(self, db: Session):
        user_repo = ServiceFactory.create_user_repository(db)
        hasher = ServiceFactory.create_password_hasher()
        self.service: IProfileService = ServiceFactory.create_profile_service(user_repo, hasher)

    def update_photo(self, user_id: int, file_bytes: bytes, content_type: str | None):
        return self.service.update_photo(user_id, file_bytes, content_type)

    def change_password(self, user_id: int, old_password: str, new_password: str):
        if not old_password or not new_password:
            raise HTTPException(status_code=400, detail="Datos incompletos")
        self.service.change_password(user_id, old_password, new_password)

    def delete_account(self, user_id: int, confirm: bool):
        if not confirm:
            raise HTTPException(status_code=400, detail="Falta confirmación")
        self.service.delete_account(user_id)

    def recover_account(self, email: str):
        self.service.recover_account(email)
