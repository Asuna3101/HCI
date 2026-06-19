/// Configuración de la API
class ApiConfig {
  /// Inyecta la URL con: --dart-define=BASE_URL=....18.91
  /// Fallback útil para emulador Android: 10.0.2.2 apunta al host
  static const String baseUrl = String.fromEnvironment('BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api/v1');

  // Timeouts y headers
  static const Duration timeout = Duration(seconds: 30);
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ---------- ROUTES ----------
  static const String loginEndpoint = '/auth/login';
  static const String loginFormEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String usersEndpoint = '/users';
  static const String currentUserEndpoint = '/users/me';
  static const String medicamentosEndpoint = '/medicamentos';
  static const String medicamentosUsuarioEndpoint =
      '/medicamentos/usuario/lista';
  static const String agregarMedicamentoEndpoint =
      '/medicamentos/usuario/registrar';
  static const String actualizarMedicamentoEndpoint =
      '/medicamentos/usuario/actualizar';
  static const String eliminarMedicamentosEndpoint =
      '/medicamentos/usuario/eliminar-lista';
  static const String unidadesEndpoint = '/unidades';
  static const String comidasEndpoint = '/comidas';
  static const String categoriasEndpoint = '/categorias';
  static const String comidasSectionsEndpoint = '/comidas/sections';
  static const String ejerciciosEndpoint = '/ejercicios';
  static const String ejerciciosUsuarioEndpoint = '/ejercicios/usuario';

  // Helper para construir URLs absolutas (normaliza /)
  static String url(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$base$p';
  }

  /// Obtener la URL base según el entorno
  static String getBaseUrl() {
    // Aquí puedes agregar lógica para diferentes entornos
    // Por ejemplo, verificar si estás en modo debug o release
    return baseUrl;
  }

  // ---------- HEALTH (catálogos EN ESPAÑOL) ----------
  static String clinics() => '$baseUrl/health/clinicas';

  static String specialties(int clinicId) =>
      '$baseUrl/health/clinicas/$clinicId/especialidades';

  // Backend espera query params: /health/doctores?clinica_id=&especialidad_id=
  static String doctors(int clinicId, int specialtyId) =>
      '$baseUrl/health/doctores?clinica_id=$clinicId&especialidad_id=$specialtyId';

  // ---------- APPOINTMENT REMINDERS ----------
  // Nombre explícito para evitar confusiones
  static String appointmentReminders() =>
      '$baseUrl/health/appointment-reminders';

  // ---------- TOMAS (medicamentos) ----------
  static String tomas() => '$baseUrl/tomas';
  static String tomasPending() => '${tomas()}/pending';
  static String tomasPostpone(int tomaId, int minutes) =>
      '${tomas()}/$tomaId/postpone?minutes=$minutes';

  // (Deprecado) Mantén temporalmente si ya usabas ApiConfig.reminders()
  @Deprecated('Usa appointmentReminders()')
  static String reminders() => appointmentReminders();

  /// Instrucciones rápidas para IP local
  static String getIpInstructions() => '''
Para conectar con tu backend local:

1) Obtén tu IP:
   - Windows: ipconfig
   - macOS/Linux: ifconfig

2) Ejecuta la app con (ejemplos):
   - Emulador Android:
     flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api/v1
   - Dispositivo físico (misma Wi-Fi):
     flutter run --dart-define=BASE_URL=http://TU_IP_LOCAL:8000/api/v1
   - iOS Simulator:
     flutter run --dart-define=BASE_URL=http://127.0.0.1:8002/api/v1

Notas:
- Evita hardcodear IPs en código; usa --dart-define.
- Si usas HTTP en dev, permite tráfico claro en AndroidManifest (usesCleartextTraffic).
''';
}
