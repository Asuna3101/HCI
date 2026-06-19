# Documentación de Contribuciones

## Historias de Usuario y Funcionalidades

### 1. Notificación y Gestión de Tomas de Medicamentos
**Historia:** Como usuario quiero marcar una dosis como tomada y recibir notificaciones de las próximas para llevar un control fiable.

**Componentes Clave:**
- Modelo: `Toma` (`app/models/toma.py`) representa cada dosis programada (`tomado`, `adquired`, `idMedxUser`).
- Repositorio: `TomaRepository` (`app/repositories/toma_repo.py`) implementa operaciones: `update_tomado`, `count_pendientes_by_medxuser`, `delete_all_by_medxuser`, `postpone_from`, `get_pending_at`.
- Servicio: `TomaService` (`app/services/toma_service.py`) añade reglas de negocio (limpia tomas cuando no quedan pendientes, valida posponer y existencia).
- Controlador: `TomaController` (`app/controllers/toma_controller.py`) gestiona errores HTTP y crea dependencias vía `ServiceFactory`.

**Flujo de Marca de Toma:**
1. Usuario marca toma → `TomaController.marcar_toma`.
2. Servicio llama `toma_repo.update_tomado`.
3. Si pendientes == 0 → `delete_all_by_medxuser` (optimiza almacenamiento / estado).
4. Retorna objeto actualizado.

**Notificaciones:** `get_pending_at` selecciona tomas en la ventana de un minuto (base para scheduler o cron externo).

**Principios SOLID Aplicados:**
- SRP: Cada capa tiene responsabilidad única (persistencia, reglas, HTTP).
- DIP: Servicio depende de `ITomaRepository` (abstracción) instanciado por `ServiceFactory`.
- ISP: Interfaces `ITomaRepository` y `ITomaService` sólo incluyen métodos necesarios.
- OCP: Se puede extender con notificaciones push sin modificar repositorio (decorador de servicio).
- LSP: Implementación concreta respeta contrato (retorna `None` en no encontrado, sin excepciones inesperadas).

**Patrones:** Repository, Service Layer, Abstract Factory (via `ServiceFactory`), Dependency Injection.

**Contribución:** Diseño limpio para completar flujo de toma y limpieza automática; interface lista para extensión con notificaciones.

---
### 2. Visualizar Lista de Alimentos
**Historia:** Como usuario quiero ver el catálogo de alimentos y buscar por nombre para seleccionarlos rápidamente.

**Componentes:**
- Modelo: `Alimento` (`app/models/comidas.py`).
- Interfaz: `IComidaRepository` (`app/interfaces/comida_repository_interface.py`).
- Repositorio: `ComidaRepository` (`app/repositories/comidas_repo.py`) con `get_all` y `search_by_nombre` (LIKE case-insensitive + orden alfabético).
- Servicio: `ComidaService` (`app/services/comida_service.py`) valida búsquedas vacías.
- Controlador: `ComidaController.listar_todas`, `buscar_por_nombre` (`app/controllers/comida_controller.py`).

**Principios SOLID:** SRP (validación mínima en servicio), DIP/ISP (servicio contra interfaz), OCP (fácil agregar filtros por categoría sin cambiar métodos existentes).

**Patrones:** Repository, Service Layer, Abstract Factory para creación en `ServiceFactory`.

**Contribución:** Implementación de búsqueda eficiente y lista paginada, con lógica desacoplada y extensible.

---
### 3. Ver Detalle de Alimento
**Historia:** Como usuario quiero ver detalles de un alimento específico.

**Flujo:** `ComidaController.obtener_por_id` → `ComidaService.obtener_por_id` → `ComidaRepository.get_by_id`.

**Principios:** SRP (manejo de 404 en controlador), DIP (servicio usa interfaz), LSP (repositorio retorna `None` sin romper contrato), OCP (se puede añadir caching envolviendo repositorio).

**Contribución:** Manejo claro de errores con 404 y estructura lista para extensión.

---
### 4. Cierre de Sesión (Logout)
**Historia:** Como usuario quiero cerrar sesión de forma segura.

**Estado Actual:** No existe endpoint explícito de logout. Se usa autenticación stateless con JWT:
- Servicio: `AuthService` (`app/services/auth_service.py`) gestiona emisión y verificación (`authenticate_and_create_token`, `verify_token`, `refresh_token`).
- Token Strategy: `JWTTokenGenerator` y `MockTokenGenerator` (`app/auth/token_generator.py`).

**Logout Actual:** Eliminación local del token (cliente). Para revocación server-side futura se agrega lista de tokens invalidados (extensión sin modificar lógica base → OCP).

**Principios:** SRP (AuthService solo autenticación), DIP (usa `ITokenGenerator`), Strategy (implementaciones intercambiables).

**Contribución:** Arquitectura preparada para incorporar revocación o expiración avanzada sin romper diseño existente.

---
### 5. Registro de Alimentos y Asociación a Usuario
**Historias:**
- Como usuario administrador quiero registrar nuevos alimentos en el catálogo.
- Como usuario quiero asociar alimentos a mi perfil con notas/categorías.

**Catálogo Global:**
- `ComidaController.crear` → `ComidaService.crear` → `ComidaRepository.create`.
- `obtener_o_crear` evita duplicados por nombre.

**Asociación Usuario-Alimento:**
- Modelo unión: `ComidaUsuario` (`app/models/comidas_usuario.py`).
- Repositorio: `ComidaUsuarioRepository` (`app/repositories/comidas_usuario_repo.py`) con `create`, `get_by_user`, `get_by_user_with_relations`, `update`, `delete_multiple`.
- Factory: `ServiceFactory.create_comida_usuario_service` permite inyectar servicio correspondiente.

**Principios:** SRP (separación catálogo vs preferencias usuario), DIP (creación via factory), ISP (repositorio unión centrado en su tabla), OCP (añadir reglas como límite por usuario en servicio).

**Contribución:** Normalización de datos (evita duplicar atributos de alimento por usuario), capacidad de extender con métricas de consumo o recomendaciones.

---
## Resumen de Patrones y SOLID
- Repository Pattern: Encapsula acceso ORM (tomas, comidas, comidas_usuario, etc.).
- Service Layer: Reglas de negocio aisladas (`TomaService`, `ComidaService`, `AuthService`).
- Abstract Factory: `ServiceFactory` centraliza instanciación y facilita pruebas/mock.
- Dependency Injection: Controladores y servicios dependen de interfaces, facilitando sustitución.
- Strategy Pattern: Generación y decodificación de tokens JWT vs mock.
- SOLID:
  - S: Responsabilidades únicas en cada clase.
  - O: Extensión por nuevas reglas sin modificar clases existentes.
  - L: Implementaciones respetan contratos de interfaces.
  - I: Interfaces específicas al dominio para evitar métodos innecesarios.
  - D: Servicios/repo operan contra abstracciones, no implementaciones concretas.

## Posibles Extensiones Futuras
- Agregar servicio de notificación push usando decorador sobre `TomaService`.
- Caching de alimentos populares mediante wrapper sobre `ComidaRepository`.
- Lista de revocación de tokens (logout server-side) en nuevo repositorio.
- Métricas de frecuencia de alimentos por usuario (nuevo servicio analítico).

## Contribución Global
Has estructurado un backend mantenible y extensible, alineado con principios SOLID, con separación clara de capas y patrones apropiados (Repository, Service, Factory, Strategy). La lógica crítica de tomas y alimentos está lista para ampliarse con notificaciones, analítica y control avanzado de autenticación.
