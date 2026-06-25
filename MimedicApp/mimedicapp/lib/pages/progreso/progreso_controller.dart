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

  Future<void> cargar() async {
    cargando.value = true;
    try {
      final data = await _service.getProgresoSemanal();
      if (data.isNotEmpty) {
        datosSemanales.assignAll(data);
      } else {
        datosSemanales.assignAll(_datosDemo());
      }
    } finally {
      cargando.value = false;
    }
  }

  List<Map<String, dynamic>> _datosDemo() {
    final hoy = DateTime.now();
    return List.generate(7, (i) {
      final dia = hoy.subtract(Duration(days: 6 - i));
      return {
        'fecha': '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}',
        'completados': i == 6 ? 0 : (i % 5) + 1,
        'total': 5,
      };
    });
  }

  double maxCompletados() {
    if (datosSemanales.isEmpty) return 5;
    return datosSemanales
        .map((d) => (d['total'] as int? ?? 5).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }
}
