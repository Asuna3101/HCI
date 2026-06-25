import 'package:get/get.dart';
import 'package:mimedicapp/models/habit.dart';
import 'package:mimedicapp/models/habit_log.dart';
import 'package:mimedicapp/models/user_progress.dart';
import 'package:mimedicapp/services/habits_service.dart';

class HomeController extends GetxController {
  final HabitsService _service;

  HomeController(this._service);

  final habitos = <Habit>[].obs;
  final logsHoy = <HabitLog>[].obs;
  final progreso = Rx<UserProgress>(UserProgress.empty);
  final cargando = false.obs;
  final procesando = <int>{}.obs;

  Set<int> get habitosCompletadosHoy =>
      logsHoy.map((l) => l.habitId).toSet();

  int get puntosHoy =>
      logsHoy.fold(0, (sum, l) => sum + l.puntosObtenidos);

  bool get todosCompletados =>
      habitos.isNotEmpty &&
      habitos.every((h) => habitosCompletadosHoy.contains(h.id));

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  Future<void> cargar() async {
    cargando.value = true;
    try {
      final results = await Future.wait([
        _service.getHabitos(),
        _service.getLogsHoy(),
        _service.getProgreso(),
      ]);
      habitos.assignAll(results[0] as List<Habit>);
      logsHoy.assignAll(results[1] as List<HabitLog>);
      progreso.value = results[2] as UserProgress;
    } finally {
      cargando.value = false;
    }
  }

  Future<void> toggleHabito(int habitoId) async {
    if (procesando.contains(habitoId)) return;
    procesando.add(habitoId);

    try {
      final yaCompletado = habitosCompletadosHoy.contains(habitoId);
      if (yaCompletado) {
        final ok = await _service.uncheckHabito(habitoId);
        if (ok) {
          logsHoy.removeWhere((l) => l.habitId == habitoId);
        }
      } else {
        final log = await _service.checkInHabito(habitoId);
        if (log != null) {
          logsHoy.add(log);
        } else {
          // Fallback optimista si la API no responde aún
          logsHoy.add(HabitLog(
            id: DateTime.now().millisecondsSinceEpoch,
            habitId: habitoId,
            fecha: DateTime.now(),
            completado: true,
            puntosObtenidos: 10,
          ));
        }
      }
      final p = await _service.getProgreso();
      progreso.value = p;
    } finally {
      procesando.remove(habitoId);
    }
  }

  String get saludo {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }
}
