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
  final datosSemanales = <Map<String, dynamic>>[].obs;

  Set<int> get habitosCompletadosHoy =>
      logsHoy.map((l) => l.habitId).toSet();

  int get puntosHoy =>
      logsHoy.fold(0, (sum, l) => sum + l.puntosObtenidos);

  bool get todosCompletados =>
      habitos.isNotEmpty &&
      habitos.every((h) => habitosCompletadosHoy.contains(h.id));

  int get pendientesHoy => habitos.length - habitosCompletadosHoy.length;

  double get porcentajeHoy {
    if (habitos.isEmpty) return 0;
    return habitosCompletadosHoy.length / habitos.length;
  }

  int get diasSinActividadReciente {
    if (datosSemanales.isEmpty) return 0;

    int dias = 0;

    for (final d in datosSemanales.reversed) {
      final completados = d['completados'] as int? ?? 0;
      if (completados == 0) {
        dias++;
      } else {
        break;
      }
    }

    return dias;
  }

  bool get necesitaRecuperacion =>
      diasSinActividadReciente >= 2 || habitosCompletadosHoy.isEmpty;

  String get recomendacionTitulo {
    if (habitos.isEmpty) return 'Empieza tu rutina';

    if (todosCompletados) {
      return '¡Excelente constancia!';
    }

    if (diasSinActividadReciente >= 3) {
      return 'Recupera tu constancia';
    }

    if (diasSinActividadReciente == 2) {
      return 'Es momento de retomar';
    }

    if (habitosCompletadosHoy.isEmpty) {
      return 'Comienza con un hábito';
    }

    if (pendientesHoy <= 2) {
      return 'Estás cerca del día perfecto';
    }

    return 'Mantén el ritmo';
  }

  String get recomendacionMensaje {
    if (habitos.isEmpty) {
      return 'Crea tu primer hábito para comenzar a construir una rutina saludable.';
    }

    if (todosCompletados) {
      return 'Completaste todos tus hábitos de hoy. Sigue así para fortalecer tu racha.';
    }

    if (diasSinActividadReciente >= 3) {
      return 'Notamos que llevas $diasSinActividadReciente días sin registrar hábitos. Retoma hoy con una acción sencilla para volver al ritmo.';
    }

    if (diasSinActividadReciente == 2) {
      return 'Has tenido una pausa reciente. Completar aunque sea un hábito hoy puede ayudarte a recuperar la constancia.';
    }

    if (habitosCompletadosHoy.isEmpty) {
      return 'Aún no completaste hábitos hoy. Empieza con uno sencillo para activar tu progreso.';
    }

    if (pendientesHoy <= 2) {
      return 'Te faltan $pendientesHoy hábito(s) para completar tu día perfecto y obtener una recompensa extra.';
    }

    return 'Ya completaste ${habitosCompletadosHoy.length} de ${habitos.length} hábitos. Continúa avanzando paso a paso.';
  }

  String get recomendacionAccion {
    if (habitos.isEmpty) return 'Crear un hábito';
    if (todosCompletados) return 'Ver logros';
    if (diasSinActividadReciente >= 2) return 'Retomar hoy';
    if (habitosCompletadosHoy.isEmpty) return 'Marcar mi primer hábito';
    if (pendientesHoy <= 2) return 'Completar pendientes';
    return 'Seguir avanzando';
  }

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
        _service.getProgresoSemanal(),
      ]);

      habitos.assignAll(results[0] as List<Habit>);
      logsHoy.assignAll(results[1] as List<HabitLog>);
      progreso.value = results[2] as UserProgress;
      datosSemanales.assignAll(
        List<Map<String, dynamic>>.from(results[3] as List),
      );
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
          logsHoy.add(
            HabitLog(
              id: DateTime.now().millisecondsSinceEpoch,
              habitId: habitoId,
              fecha: DateTime.now(),
              completado: true,
              puntosObtenidos: 10,
            ),
          );
        }
      }

      final p = await _service.getProgreso();
      final semanal = await _service.getProgresoSemanal();

      progreso.value = p;
      datosSemanales.assignAll(semanal);
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