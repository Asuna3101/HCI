import 'package:get/get.dart';
import 'package:mimedicapp/models/achievement.dart';
import 'package:mimedicapp/services/habits_service.dart';

class LogrosController extends GetxController {
  final HabitsService _service;

  LogrosController(this._service);

  final logros = <Achievement>[].obs;
  final cargando = false.obs;

  int get desbloqueados => logros.where((l) => l.desbloqueado).length;

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
      final data = await _service.getLogros();
      logros.assignAll(data);
    } finally {
      cargando.value = false;
    }
  }
}