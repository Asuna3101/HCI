"""
Controlador de Login - Solo manejo de autenticación
"""
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.factories.service_factory import ServiceFactory


class UserController:
    """Controlador simplificado solo para login"""
    
    def __init__(self, db: Session):
        repository = ServiceFactory.create_user_repository(db)
        password_hasher = ServiceFactory.create_password_hasher()
        token_generator = ServiceFactory.create_token_generator()

        self.user_service = ServiceFactory.create_user_service(repository, password_hasher)
        self.auth_service = ServiceFactory.create_auth_service(self.user_service, token_generator)

    def authenticate_user(self, correo: str, password: str) -> dict:
        """Autenticar usuario y generar token"""
        try:
            # Crear servicio de autenticación
            token_generator = ServiceFactory.create_token_generator()
            auth_service = ServiceFactory.create_auth_service(self.user_service, token_generator)
            
            # Autenticar y crear token
            auth_result = auth_service.authenticate_and_create_token(correo, password)
            
            if not auth_result:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Credenciales incorrectas",
                    headers={"WWW-Authenticate": "Bearer"}
                )
            
            return {
                "access_token": auth_result["access_token"],
                "token_type": auth_result["token_type"]
            }
            
        except ValueError as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error interno del servidor"
            )

    def register_user(self, correo: str, password: str, nombre: str, fecha_nacimiento, celular: str):
        """Registrar usuario delegando en el servicio de usuarios"""
        try:
            created = self.user_service.register_user(
                correo=correo,
                password=password,
                nombre=nombre,
                fecha_nacimiento=fecha_nacimiento,
                celular=celular,
            )
            return created
        except ValueError as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    
    def get_current_user_from_token(self, token: str):
        """Obtiene el usuario autenticado a partir del token."""
        user = self.auth_service.get_user_from_token(token)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido o usuario no encontrado"
            )
        return user