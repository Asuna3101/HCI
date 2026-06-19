import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mimedicapp/configs/api_config.dart';

/// Servicio HTTP base (login, headers con token, métodos GET/POST/PUT/DELETE).
/// - Guarda/lee el JWT en SharedPreferences bajo la clave `auth_token`.
/// - Usa los endpoints definidos en `ApiConfig`.
class ApiService {
  // --------------- Singleton ---------------
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // --------------- Estado / Token ---------------
  String? _authToken; // cacheado en memoria

  /// Devuelve la URL absoluta combinando base + endpoint relativo.
  /// Si `endpoint` ya es absoluto, lo devuelve tal cual.
  String _abs(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }
    // Usa el helper de ApiConfig para normalizar slashes
    return ApiConfig.url(endpoint);
  }

  /// Lee el token del cache o de SharedPreferences
  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  /// Persiste el token
  Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Borra el token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // --------------- Headers ---------------
  Future<Map<String, String>> _headers({bool withAuth = false}) async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (withAuth) {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final raw = response.body;

    dynamic data;
    try {
      data = raw.isEmpty ? null : json.decode(raw);
    } catch (_) {
      data = null;
    }

    // Log útil para diagnósticos (mantenlo mientras depuras)
    // ignore: avoid_print
    print('[API] <- $status ${response.request?.method} ${response.request?.url}');
    if (raw.isNotEmpty) {
      // ignore: avoid_print
      print('[API] RESP BODY: $raw');
    }

    // OK
    if (status >= 200 && status < 300) {
      return data ?? raw;
    }

    // Error: intenta extraer el "detail" de FastAPI
    final msg = _extractDetail(data) ?? 'HTTP $status';

    switch (status) {
      case 400:
        throw ApiException(msg.isEmpty ? 'Solicitud inválida' : msg);
      case 401:
        throw ApiException('No autorizado - Token inválido o expirado');
      case 403:
        throw ApiException('Acceso denegado');
      case 404:
        throw ApiException('Recurso no encontrado');
      case 409:
        throw ApiException(msg.isEmpty ? 'Conflicto: recurso en uso' : msg);
      case 422:
        throw ApiException(msg.isEmpty ? 'Error de validación' : msg);
      case 500:
        throw ApiException('Error interno del servidor');
      default:
        throw ApiException('Error inesperado: $status');
    }
  }

  String? _extractDetail(dynamic data) {
    try {
      if (data == null) return null;

      // FastAPI: {"detail": "..."} o {"detail": [{loc: [...], msg: "...", type: "..."}]}
      if (data is Map && data['detail'] != null) {
        final d = data['detail'];
        if (d is String) return d;
        if (d is List) {
          // Junta los mensajes de validación: "clinic_id: field required | starts_at: invalid datetime ..."
          return d.map((e) {
            if (e is Map) {
              final loc = (e['loc'] is List) ? (e['loc'] as List).join('.') : e['loc'];
              final msg = e['msg'] ?? e.toString();
              return loc != null ? '$loc: $msg' : msg.toString();
            }
            return e.toString();
          }).join(' | ');
        }
        return d.toString();
      }

      // A veces FastAPI devuelve una lista directamente (p. ej. 422)
      if (data is List) {
        return data.map((e) {
          if (e is Map) return e['msg'] ?? e.toString();
          return e.toString();
        }).join(' | ');
      }
    } catch (_) {}
    return null;
  }


  Future<dynamic> get(String endpoint, {bool auth = true}) async {
    try {
      final url = _abs(endpoint);
      final headers = await _headers(withAuth: auth);


      // ignore: avoid_print
      print('[API] -> GET  $url');
      // ignore: avoid_print
      print('[API] HEADERS: $headers');

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response); // ya imprime RESP BODY
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } on HttpException catch (e) {
      throw ApiException('HTTP error: $e');
    } on FormatException {
      throw ApiException('Respuesta no válida del servidor');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data, {bool auth = true}) async {
    try {
      final url = _abs(endpoint);
      final headers = await _headers(withAuth: auth);
      final body = json.encode(data);

      // logs
      // ignore: avoid_print
      print('[API] -> PATCH $url');
      // ignore: avoid_print
      print('[API] HEADERS: $headers');
      // ignore: avoid_print
      print('[API] BODY   : $body');

      final response = await http
          .patch(Uri.parse(url), headers: headers, body: body)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }


  Future<dynamic> post(String endpoint, Map<String, dynamic> data, {bool auth = true}) async {
    try {
      final url = _abs(endpoint);
      final headers = await _headers(withAuth: auth);
      final body = json.encode(data);

      // Logs de salida
      // ignore: avoid_print
      print('[API] -> POST $url');
      // ignore: avoid_print
      print('[API] HEADERS: $headers');
      // ignore: avoid_print
      print('[API] BODY   : $body');

      final response = await http
          .post(Uri.parse(url), headers: headers, body: body)
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data, {bool auth = true}) async {
    try {
      final url = _abs(endpoint);
      final headers = await _headers(withAuth: auth);
      final body = json.encode(data);

      // ignore: avoid_print
      print('[API] -> PUT  $url');
      // ignore: avoid_print
      print('[API] HEADERS: $headers');
      // ignore: avoid_print
      print('[API] BODY   : $body');

      final response = await http
          .put(Uri.parse(url), headers: headers, body: body)
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }


  Future<dynamic> delete(String endpoint, {bool auth = true}) async {
    try {
      final response = await http
          .delete(
            Uri.parse(_abs(endpoint)),
            headers: await _headers(withAuth: auth),
          )
          .timeout(ApiConfig.timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }

  /// Subir archivo multipart (solo mobile/desktop).
  Future<dynamic> uploadFile(String endpoint, String fieldName, File file,
      {bool auth = true, Map<String, String>? extraFields, String method = 'POST'}) async {
    try {
      final uri = Uri.parse(_abs(endpoint));
      final request = http.MultipartRequest(method, uri);
      request.headers.addAll(await _headers(withAuth: auth));
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      extraFields?.forEach((k, v) => request.fields[k] = v);

      // ignore: avoid_print
      print('[API] -> UPLOAD $uri (${file.path})');

      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }

  Future<dynamic> deleteRest(
      String endpoint, {
      bool auth = true,
      Map<String, dynamic>? body,
    })async {
    try {
      final request = http.Request(
        'DELETE',
        Uri.parse(_abs(endpoint)),
      );

      request.headers.addAll(await _headers(withAuth: auth));

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final streamed = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamed);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error inesperado: $e');
    }
  }

  /// GET devolviendo bytes (para descargas)
  Future<http.Response> getBytes(String endpoint, {bool auth = true}) async {
    final url = _abs(endpoint);
    final headers = await _headers(withAuth: auth);
    // ignore: avoid_print
    print('[API] -> GET(bytes) $url');
    final resp = await http.get(Uri.parse(url), headers: headers).timeout(ApiConfig.timeout);
    return resp;
  }

  // --------------- Login / Logout ---------------
  /// Login JSON: { correo, password } → { access_token, token_type }
  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    final payload = {'correo': email, 'password': password};
    final resp = await post(ApiConfig.loginEndpoint, payload, auth: false);

    final token = resp is Map<String, dynamic> ? resp['access_token'] : null;
    if (token is String && token.isNotEmpty) {
      await saveAuthToken(token);
    }
    return resp is Map<String, dynamic> ? resp : <String, dynamic>{};
  }

  /// Login (form-url-encoded). Útil si tu backend expone esa variante.
  Future<Map<String, dynamic>> loginWithForm(String email, String password) async {
    try {
      final headers = Map<String, String>.from(ApiConfig.defaultHeaders)
        ..['Content-Type'] = 'application/x-www-form-urlencoded';

      final body = 'username=$email&password=$password';
      final response = await http
          .post(
            Uri.parse(_abs(ApiConfig.loginFormEndpoint)),
            headers: headers,
            body: body,
          )
          .timeout(ApiConfig.timeout);

      final resp = _handleResponse(response);
      final token = (resp is Map<String, dynamic>) ? resp['access_token'] : null;
      if (token is String && token.isNotEmpty) {
        await saveAuthToken(token);
      }
      return resp is Map<String, dynamic> ? resp : <String, dynamic>{};
    } on SocketException {
      throw ApiException('Sin conexión. Verifica tu internet.');
    }
  }

  /// Cierra sesión local (borra token)
  Future<void> logout() async => clearAuthToken();
}

/// Excepción propia para los errores de API
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}
