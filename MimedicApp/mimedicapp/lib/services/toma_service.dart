import 'package:mimedicapp/services/api_service.dart';
import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/models/toma.dart';

class TomaService {
  TomaService([ApiService? api]) : _api = api ?? ApiService();
  final ApiService _api;

  Future<List<Toma>> getPendingTomas({DateTime? at}) async {
    final uri = at == null ? ApiConfig.tomasPending() : '${ApiConfig.tomasPending()}?at=${at.toUtc().toIso8601String()}';
    final data = await _api.get(uri, auth: true);
    return (data as List).map((e) => Toma.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markTomado(int tomaId, bool tomado) async {
    await _api.patch('${ApiConfig.tomas()}/$tomaId', {'tomado': tomado}, auth: true);
  }

  Future<int> postponeTomas(int tomaId, int minutes) async {
    final resp = await _api.patch(ApiConfig.tomasPostpone(tomaId, minutes), {}, auth: true);
    if (resp is Map && resp['updated'] is int) return resp['updated'] as int;
    return 0;
  }
}
