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

  // ---------- AUTH ----------
  static const String loginEndpoint = '/auth/login';
  static const String loginFormEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String usersEndpoint = '/users';
  static const String currentUserEndpoint = '/users/me';

  // ---------- HÁBITOS ----------
  static const String habitosEndpoint = '/habitos';
  static const String habitosLogsEndpoint = '/habitos/logs';
  static const String habitosProgresoEndpoint = '/habitos/progreso';

  // ---------- GAMIFICACIÓN ----------
  static const String gamificacionProgresoEndpoint = '/gamificacion/progreso';
  static const String logrosEndpoint = '/gamificacion/logros';

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

  // ---------- HÁBITOS (helpers) ----------
  static String habitoCheckIn(int habitoId) =>
      '$baseUrl/habitos/$habitoId/check-in';

  static String habitoLogs({String? fecha, int? dias}) {
    final params = <String>[];
    if (fecha != null) params.add('fecha=$fecha');
    if (dias != null) params.add('dias=$dias');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    return '$baseUrl/habitos/logs$query';
  }

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
     flutter run --dart-define=BASE_URL=http://127.0.0.1:8000/api/v1

Notas:
- Evita hardcodear IPs en código; usa --dart-define.
- Si usas HTTP en dev, permite tráfico claro en AndroidManifest (usesCleartextTraffic).
''';
}
