from fastapi import FastAPI
from sqlalchemy import text
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.endpoints import auth, medicamentoxusuario, toma, unidad, healthcare, appointment_reminders, ejercicioxusuario, comidas, categorias, users, reportes, profile
from app.core.database import engine
from app.models import base
from app.seeders.run_seeders import run_all_seeders

# Reinicia el esquema en cada arranque según lo solicitado: drop, create, seed.
with engine.begin() as conn:
    conn.execute(text("DROP SCHEMA public CASCADE"))
    conn.execute(text("CREATE SCHEMA public"))
base.Base.metadata.create_all(bind=engine)
run_all_seeders()
app = FastAPI(
    title="MimedicApp Login API",
    version=settings.PROJECT_VERSION,
    description="API simplificada solo para login/autenticación",
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["authentication"])
app.include_router(medicamentoxusuario.router,prefix=f"{settings.API_V1_STR}/medicamentos",tags=["medicamentos-usuario"],)
app.include_router(unidad.router,prefix=f"{settings.API_V1_STR}/unidades",tags=["catalogo-unidades"])
app.include_router(toma.router,prefix=f"{settings.API_V1_STR}/tomas",tags=["tomas"],)
app.include_router(healthcare.router,prefix=f"{settings.API_V1_STR}/health",tags=["healthcare"],)
app.include_router(appointment_reminders.router,prefix=f"{settings.API_V1_STR}/health/appointment-reminders",tags=["citas"],)
app.include_router(ejercicioxusuario.router,prefix=f"{settings.API_V1_STR}/ejercicios",tags=["ejercicios"],)
app.include_router(comidas.router,prefix=f"{settings.API_V1_STR}/comidas",tags=["comidas-catalogo"],)
app.include_router(categorias.router,prefix=f"{settings.API_V1_STR}/categorias",tags=["categorias"],)
app.include_router(users.router,prefix=f"{settings.API_V1_STR}/users",tags=["users"],)
app.include_router(reportes.router,prefix=f"{settings.API_V1_STR}/reportes",tags=["reportes"],)
app.include_router(profile.router,prefix=f"{settings.API_V1_STR}/profile",tags=["profile"],)

@app.get("/")
def read_root():
    """Endpoint raíz"""
    return {
        "message": "MimedicApp Login API",
        "version": settings.PROJECT_VERSION,
        "description": "API simplificada solo para login",
        "docs": "/docs",
        "login_endpoint": f"{settings.API_V1_STR}/auth/login"
    }

@app.get("/health")
def health_check():
    """Endpoint de health check"""
    return {
        "status": "healthy", 
        "service": "login-only",
        "version": settings.PROJECT_VERSION
    }
