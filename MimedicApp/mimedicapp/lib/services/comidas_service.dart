import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/models/comida.dart';
import 'package:mimedicapp/services/api_service.dart';

class ComidasService {
  final ApiService _api = ApiService();

  /// Obtiene todas las comidas del usuario autenticado
  Future<List<Comida>> getComidasUsuario() async {
    final response = await _api.get('${ApiConfig.comidasEndpoint}/usuario');
    final List data = response as List;
    return data.map((e) => Comida.fromJson(e)).toList();
  }

  /// Busca comidas en el catálogo por nombre (autocompletado)
  Future<List<Map<String, dynamic>>> buscarComidas(String query) async {
    if (query.isEmpty) return [];
    final response = await _api.get(
        '${ApiConfig.comidasEndpoint}/buscar/?q=${Uri.encodeComponent(query)}&limit=20');
    final List data = response as List;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Obtiene las categorías (Recomendable/No Recomendable)
  Future<List<Map<String, dynamic>>> getCategorias() async {
    final response = await _api.get(ApiConfig.categoriasEndpoint);
    final List data = response as List;
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Registra una nueva comida para el usuario
  Future<Comida> registrarComida({
    required String nombre,
    String? descripcion,
    int? idCategoria,
  }) async {
    final payload = {
      'nombre': nombre,
      if (descripcion != null && descripcion.isNotEmpty)
        'descripcion': descripcion,
      if (idCategoria != null) 'idCategoria': idCategoria,
    };

    final response = await _api.post(
      '${ApiConfig.comidasEndpoint}/usuario',
      payload,
    );
    return Comida.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza una comida del usuario
  Future<Comida> actualizarComida(
    int id, {
    String? nombre,
    String? descripcion,
    int? idCategoria,
  }) async {
    final payload = {
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (idCategoria != null) 'idCategoria': idCategoria,
    };

    final response = await _api.put(
      '${ApiConfig.comidasEndpoint}/usuario/$id',
      payload,
    );
    return Comida.fromJson(response as Map<String, dynamic>);
  }

  /// Elimina múltiples comidas del usuario
  Future<void> eliminarComidas(List<int> ids) async {
    await _api.deleteRest(
      '${ApiConfig.comidasEndpoint}/usuario',
      body: {'ids': ids},
    );
  }
}
