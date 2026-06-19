"""
Servicio simplificado solo para autenticación
"""
from typing import Optional
from datetime import date

from app.models.user import User
from app.interfaces.user_service_interface import IUserService
from app.interfaces.user_repository_interface import IUserRepository
from app.interfaces.auth_interface import IPasswordHasher


class UserService(IUserService):
    """Servicio simplificado solo para login"""
    
    def __init__(self, repository: IUserRepository, password_hasher: IPasswordHasher):
        self.repository = repository
        self.password_hasher = password_hasher
    
    def get_user_by_email(self, email: str) -> Optional[User]:
        """Obtener usuario por correo"""
        return self.repository.get_by_email(email)
    
    def authenticate_user(self, email: str, password: str) -> Optional[User]:
        """Autenticar usuario por correo o username"""
        # Buscar por correo (en nuestro caso, username es el correo)
        user = self.repository.get_by_email(email)
        
        # Verificar contraseña
        if not user or not self.password_hasher.verify_password(password, user.hashed_password):
            return None
        
        # Verificar que el usuario esté activo
        if not user.is_active:
            raise ValueError("Usuario inactivo")
        
        return user

    def register_user(
        self,
        correo: str,
        password: str,
        nombre: str,
        fecha_nacimiento: date,
        celular: str,
    ) -> User:
        """Registrar un nuevo usuario.

        - Verifica que no exista un usuario con el mismo correo.
        - Valida contraseña mínima (no vacía).
        - Hashea la contraseña y delega la creación al repositorio.

        Lanza ValueError en caso de datos inválidos o si ya existe el correo.
        """
        # Validaciones básicas
        if not correo or not correo.strip():
            raise ValueError("El correo es obligatorio")
        if not password or not str(password).strip():
            raise ValueError("La contraseña es obligatoria")
        if not nombre or not nombre.strip():
            raise ValueError("El nombre es obligatorio")
        if not fecha_nacimiento:
            raise ValueError("La fecha de nacimiento es obligatoria")
        if not celular or not celular.strip():
            raise ValueError("El celular es obligatorio")

        # Verificar existencia previa
        if self.repository.exists_by_email(correo):
            raise ValueError("Usuario con este correo ya existe")

        # Hashear la contraseña
        hashed = self.password_hasher.hash_password(password)

        # Preparar datos para el repositorio (keys según modelo User)
        user_data = {
            "correo": correo,
            "hashed_password": hashed,
            "nombre": nombre or "",
            "fecha_nacimiento": fecha_nacimiento,
            "celular": celular,
            "is_active": True,
        }

        # Crear usuario en persistencia
        created = self.repository.create(user_data)

        return created