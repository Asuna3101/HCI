import '../models/usuario.dart';
import 'api_service.dart';
import '../configs/api_config.dart';

class UserService {
  final ApiService _apiService = ApiService();

  /// Crear un nuevo usuario (registro)
  Future<Usuario> createUser(Usuario usuario) async {
    try {
      final userData = usuario.toRegistrationJson();

      // Loguea la URL real sin tocar baseUrl a mano
      final fullUrl = ApiConfig.url(ApiConfig.registerEndpoint);
      print('Register URL: $fullUrl');
      print('Register payload: $userData');

      final response =
          await _apiService.post(ApiConfig.registerEndpoint, userData, auth: false);

      return Usuario(
        idUsuario: response['id'],
        nombre: usuario.nombre,
        fechaNacimiento: usuario.fechaNacimiento,
        celular: usuario.celular,
        correo: usuario.correo,
        contrasena: '', // nunca devolver password
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al crear usuario: $e');
    }
  }

  /// Usuario actual (usa endpoint de ApiConfig)
  Future<Usuario> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.currentUserEndpoint);
      return Usuario(
        idUsuario: response['id'],
        nombre: response['nombre'],
        fechaNacimiento: DateTime.parse(response['fecha_nacimiento']),
        celular: response['celular'] ?? '',
        correo: response['correo'],
        contrasena: '',
        foto: response['photo'],
        fotoContentType: response['photo_content_type'],
      );
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  /// Obtener usuario por ID
  Future<Usuario> getUserById(int userId) async {
    try {
      final response = await _apiService.get('${ApiConfig.usersEndpoint}/$userId');
      return Usuario(
        idUsuario: response['id'],
        nombre: response['nombre'],
        fechaNacimiento: DateTime.parse(response['fecha_nacimiento']),
        celular: response['celular'] ?? '',
        correo: response['correo'],
        contrasena: '',
        foto: response['photo'],
        fotoContentType: response['photo_content_type'],
      );
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Actualizar usuario
  Future<Usuario> updateUser(int userId, Map<String, dynamic> updateData) async {
    try {
      if (updateData['fechaNacimiento'] != null) {
        updateData['fecha_nacimiento'] =
            updateData['fechaNacimiento'].toIso8601String().split('T')[0];
        updateData.remove('fechaNacimiento');
      }
      if (updateData['contrasena'] != null) {
        updateData['password'] = updateData['contrasena'];
        updateData.remove('contrasena');
      }

      final response =
          await _apiService.put('${ApiConfig.usersEndpoint}/$userId', updateData);

      return Usuario(
        idUsuario: response['id'],
        nombre: response['nombre'],
        fechaNacimiento: DateTime.parse(response['fecha_nacimiento']),
        celular: response['celular'] ?? '',
        correo: response['correo'],
        contrasena: '',
        foto: response['photo'],
        fotoContentType: response['photo_content_type'],
      );
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  /// Eliminar usuario
  Future<void> deleteUser(int userId) async {
    try {
      await _apiService.delete('${ApiConfig.usersEndpoint}/$userId');
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  /// Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _apiService.loginWithEmail(email, password);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// ¿Autenticado?
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> requestRecover(String email) async {
    await _apiService.post('/auth/recover/request', {'email': email}, auth: false);
  }

  Future<void> confirmRecover(
      {required String email, required String code, required String newPassword}) async {
    await _apiService.post('/auth/recover/confirm',
        {'email': email, 'code': code, 'new_password': newPassword},
        auth: false);
  }
}
