from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.factories.service_factory import ServiceFactory
from app.interfaces.report_service_interface import IReportService


class ReportController:
    def __init__(self, db: Session):
        self.service: IReportService = ServiceFactory.create_report_service(db)

    def summary(self, user_id: int):
        return self.service.get_summary(user_id)

    def module_events(self, user_id: int, module: str):
        return self.service.get_module_events(user_id, module)

    def module_download(self, user_id: int, module: str, fmt: str = "txt"):
        return self.service.download_module(user_id, module, fmt)
