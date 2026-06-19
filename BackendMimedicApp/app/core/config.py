"""
Configuración de la aplicación
"""
from typing import List
from pydantic_settings import BaseSettings
from decouple import config


class Settings(BaseSettings):
    # Configuración general
    PROJECT_NAME: str = config("PROJECT_NAME", default="Mobile App Backend")
    PROJECT_VERSION: str = config("PROJECT_VERSION", default="1.0.0")
    API_V1_STR: str = config("API_V1_STR", default="/api/v1")
    
    # Seguridad
    SECRET_KEY: str = config("SECRET_KEY", default="your-secret-key-change-in-production")
    ALGORITHM: str = config("ALGORITHM", default="HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = config("ACCESS_TOKEN_EXPIRE_MINUTES", default=300, cast=int)
    
    # Base de datos
    DATABASE_URL: str = config("DATABASE_URL", default="sqlite:///./app.db")
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000", 
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:*",  # Para Flutter
        "http://127.0.0.1:*",  # Para Flutter
        "*"  # Permitir todos los orígenes en desarrollo (remover en producción)
    ]
    
    # Archivos
    MAX_FILE_SIZE: int = config("MAX_FILE_SIZE", default=10485760, cast=int)  # 10MB
    UPLOAD_FOLDER: str = config("UPLOAD_FOLDER", default="uploads")
    
    # Debug
    DEBUG: bool = config("DEBUG", default=False, cast=bool)

    class Config:
        env_file = ".env"


# Instancia global de configuración
settings = Settings()