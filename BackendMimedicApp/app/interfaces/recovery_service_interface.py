from abc import ABC, abstractmethod

class IRecoveryService(ABC):
    @abstractmethod
    def request_code(self, email: str) -> None:
        raise NotImplementedError

    @abstractmethod
    def confirm_code(self, email: str, code: str, new_password: str) -> None:
        raise NotImplementedError
