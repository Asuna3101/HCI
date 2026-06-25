import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/models/achievement.dart';
import 'package:mimedicapp/models/habit.dart';
import 'package:mimedicapp/models/habit_log.dart';
import 'package:mimedicapp/models/user_progress.dart';
import 'package:mimedicapp/services/api_service.dart';

class HabitsService {
  final ApiService _api;

  HabitsService(this._api);

  Future<List<Habit>> getHabitos() async {
    try {
      final data = await _api.get(ApiConfig.habitosEndpoint);
      if (data is List) {
        return data
            .map((e) => Habit.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return Habit.predefinidos;
  }

  Future<List<HabitLog>> getLogsHoy() async {
    final hoy = DateTime.now();
    final fecha =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    try {
      final data =
          await _api.get('${ApiConfig.habitosLogsEndpoint}?fecha=$fecha');
      if (data is List) {
        return data
            .map((e) => HabitLog.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<HabitLog?> checkInHabito(int habitoId) async {
    final hoy = DateTime.now();
    final fecha =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    try {
      final data = await _api.post(
        ApiConfig.habitoCheckIn(habitoId),
        {'fecha': fecha},
      );
      if (data is Map<String, dynamic>) {
        return HabitLog.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> uncheckHabito(int habitoId) async {
    final hoy = DateTime.now();
    final fecha =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    try {
      await _api.delete(
          '${ApiConfig.habitoCheckIn(habitoId)}?fecha=$fecha');
      return true;
    } catch (_) {}
    return false;
  }

  Future<List<Map<String, dynamic>>> getProgresoSemanal() async {
    try {
      final data = await _api.get(
          '${ApiConfig.habitosProgresoEndpoint}?dias=7');
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return [];
  }

  Future<UserProgress> getProgreso() async {
    try {
      final data = await _api.get(ApiConfig.gamificacionProgresoEndpoint);
      if (data is Map<String, dynamic>) {
        return UserProgress.fromJson(data);
      }
    } catch (_) {}
    return UserProgress.empty;
  }

  Future<List<Achievement>> getLogros() async {
    try {
      final data = await _api.get(ApiConfig.logrosEndpoint);
      if (data is List) {
        return data
            .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return Achievement.todos;
  }
}
