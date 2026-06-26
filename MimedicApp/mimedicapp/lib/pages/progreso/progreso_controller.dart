import 'package:get/get.dart';
import 'package:mimedicapp/services/habits_service.dart';

class ProgresoController extends GetxController {
  final HabitsService _service;

  ProgresoController(this._service);

  final datosSemanales = <Map<String, dynamic>>[].obs;
  final cargando = false.obs;

  @override
  void onInit() {
    super.onInit();
    cargar();
  }

  @override
  void onReady() {
    super.onReady();
    cargar();
  }

  Future<void> cargar() async {
    cargando.value = true;
    try {
      final data = await _service.getProgresoSemanal();
      datosSemanales.assignAll(data.isNotEmpty ? data : _datosVacios());
    } finally {
      cargando.value = false;
    }
  }

  List<Map<String, dynamic>> _datosVacios() {
    final hoy = DateTime.now();
    return List.generate(7, (i) {
      final dia = hoy.subtract(Duration(days: 6 - i));
      return {
        'fecha':
            '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}',
        'completados': 0,
        'total': 5,
      };
    });
  }

  int get totalCompletados {
    return datosSemanales.fold<int>(
      0,
      (sum, d) => sum + (d['completados'] as int? ?? 0),
    );
  }

  int get totalPosibles {
    return datosSemanales.fold<int>(
      0,
      (sum, d) => sum + (d['total'] as int? ?? 5),
    );
  }

  int get diasActivos {
    return datosSemanales
        .where((d) => (d['completados'] as int? ?? 0) > 0)
        .length;
  }

  int get diasPerfectos {
    return datosSemanales.where((d) {
      final completados = d['completados'] as int? ?? 0;
      final total = d['total'] as int? ?? 5;
      return total > 0 && completados >= total;
    }).length;
  }

  double get porcentajeCumplimiento {
    if (totalPosibles == 0) return 0;
    return totalCompletados / totalPosibles;
  }

  double get promedioDiario {
    if (datosSemanales.isEmpty) return 0;
    return totalCompletados / datosSemanales.length;
  }

  int get mejorDiaCantidad {
    if (datosSemanales.isEmpty) return 0;
    return datosSemanales
        .map((d) => d['completados'] as int? ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  String get mejorDiaNombre {
    if (datosSemanales.isEmpty) return '-';

    Map<String, dynamic> mejor = datosSemanales.first;

    for (final d in datosSemanales) {
      final actual = d['completados'] as int? ?? 0;
      final mejorActual = mejor['completados'] as int? ?? 0;
      if (actual > mejorActual) mejor = d;
    }

    final fecha = DateTime.parse(mejor['fecha'] as String);
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[fecha.weekday - 1];
  }

  String get feedbackInteligente {
    if (totalCompletados == 0) {
      return 'Aún no registras hábitos esta semana. Empieza con uno pequeño para retomar el ritmo.';
    }

    if (diasPerfectos >= 5) {
      return 'Excelente semana. Tu constancia está muy alta y estás cerca de consolidar una rutina estable.';
    }

    if (porcentajeCumplimiento >= 0.75) {
      return 'Vas muy bien. Mantén este ritmo para cerrar la semana con un alto cumplimiento.';
    }

    if (porcentajeCumplimiento >= 0.45) {
      return 'Tienes un avance moderado. Intenta completar al menos un hábito más por día.';
    }

    return 'Tu cumplimiento está bajo esta semana. Prioriza hábitos simples para recuperar la constancia.';
  }

  double maxCompletados() {
    if (datosSemanales.isEmpty) return 5;
    return datosSemanales
        .map((d) => (d['total'] as int? ?? 5).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }
}