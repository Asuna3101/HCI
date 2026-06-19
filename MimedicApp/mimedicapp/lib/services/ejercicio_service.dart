import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/models/ejercicio.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/services/api_service.dart';

class EjercicioService {
  final ApiService _apiService = ApiService();

  Future<List<Ejercicio>> getEjercicios() async {
    final response = await _apiService.get(ApiConfig.ejerciciosEndpoint);
    final List data = response as List;
    return data.map((e) => Ejercicio.fromJson(e)).toList();
  }

  Future<List<EjercicioUsuario>> getEjerciciosUsuario() async {
    final response = await _apiService.get(ApiConfig.ejerciciosUsuarioEndpoint);
    final List data = response as List;
    return data.map((e) => EjercicioUsuario.fromJson(e)).toList();
  }

  Future<EjercicioUsuario> createEjercicioUsuario(
      EjercicioUsuario ejercicioUsuario) async {
    try {
      final response = await _apiService.post(
        ApiConfig.ejerciciosUsuarioEndpoint,
        ejercicioUsuario.toJson(),
      );

      return EjercicioUsuario.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al registrar ejercicio: $e');
    }
  }

  Future<EjercicioUsuario> updateEjercicioUsuario(
      int id, EjercicioUsuario data) async {
    try {
      final response = await _apiService.put(
        "${ApiConfig.ejerciciosUsuarioEndpoint}/$id",
        data.toJson(),
      );

      return EjercicioUsuario.fromJson(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al actualizar ejercicio: $e');
    }
  }

  Future<void> deleteEjerciciosUsuario(List<int> ids) async {
    try {
      final body = {'ids': ids};
      await _apiService.deleteRest(
        ApiConfig.ejerciciosUsuarioEndpoint,
        body: body
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error al eliminar ejercicios: $e');
    }
  }
}
