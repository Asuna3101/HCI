from sqlalchemy.orm import Session
from app.factories.service_factory import ServiceFactory
from app.interfaces.recovery_service_interface import IRecoveryService


class RecoveryController:
    def __init__(self, db: Session):
        user_repo = ServiceFactory.create_user_repository(db)
        hasher = ServiceFactory.create_password_hasher()
        self.service: IRecoveryService = ServiceFactory.create_recovery_service(
            user_repo, hasher
        )

    def request(self, email: str):
        self.service.request_code(email)

    def confirm(self, email: str, code: str, new_password: str):
        self.service.confirm_code(email, code, new_password)
