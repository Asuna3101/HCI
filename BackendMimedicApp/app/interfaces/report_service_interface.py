from abc import ABC, abstractmethod
from typing import List, Dict, Any


class IReportService(ABC):
    @abstractmethod
    def get_summary(self, user_id: int) -> Dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    def get_module_events(self, user_id: int, module: str) -> List[Dict[str, Any]]:
        raise NotImplementedError

    @abstractmethod
    def download_module(self, user_id: int, module: str, fmt: str = "txt") -> tuple[bytes, str, str]:
        raise NotImplementedError
