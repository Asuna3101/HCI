"""
Implementaciones de hasheo de contraseñas
"""
from app.interfaces.auth_interface import IPasswordHasher

# Requiere: pip install bcrypt
import bcrypt


class BcryptPasswordHasher(IPasswordHasher):
    """Hasheo seguro con bcrypt"""

    def hash_password(self, password: str) -> str:
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode("utf-8"), salt)
        return hashed.decode("utf-8")

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        try:
            return bcrypt.checkpw(
                plain_password.encode("utf-8"),
                hashed_password.encode("utf-8"),
            )
        except Exception:
            return False


# (Opcional) Solo para pruebas locales. NO usar en producción.
class SimplePasswordHasher(IPasswordHasher):
    import hashlib

    def hash_password(self, password: str) -> str:
        return self.hashlib.sha256(password.encode("utf-8")).hexdigest()

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return self.hash_password(plain_password) == hashed_password


__all__ = ["BcryptPasswordHasher", "SimplePasswordHasher"]
