// lib/pages/home/citas/citas_controller.dart
import 'package:get/get.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/pages/home/home_routes.dart';

class CitasListController extends GetxController {
  CitasListController(this._service);
  final HealthService _service;

  final cargando = false.obs;
  final proximas = <AppointmentReminder>[].obs;

  // Modo de selección y lista de ids seleccionados
  final selectionMode = false.obs;
  final selectedIds = <int>[].obs;

  void toggleSelectionMode() {
    selectionMode.value = !selectionMode.value;
    if (!selectionMode.value) {
      // limpiar selección al salir del modo
      selectedIds.clear();
    }
  }

  void toggleSelect(AppointmentReminder appointment) {
    final id = appointment.id;
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  @override
  void onReady() {
    super.onReady();
    cargar();
  }

  Future<void> cargar() async {
    cargando.value = true;
    try {
      final ups = await _service.getUpcomingReminders();
      proximas
        ..assignAll(ups)
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    } finally {
      cargando.value = false;
    }
  }

  Future<void> changeStatus(AppointmentReminder r, AppointmentStatus newStatus) async {
    final idx = proximas.indexWhere((x) => x.id == r.id);
    if (idx == -1) return;

    // Optimistic update: decide efecto en UI
    final removeFromUpcoming = (newStatus != AppointmentStatus.pendiente);

    // Aplica cambios visuales
    if (removeFromUpcoming) {
      final removed = proximas.removeAt(idx);
      update();

      try {
        await _service.updateAppointmentStatus(reminderId: r.id, status: newStatus);
      } catch (e) {
        // Revertir si falla
        proximas.insert(idx, removed);
        update();
        rethrow;
      }
    } else {
      // Cambiar a pendiente: no removemos; solo mandamos al back
      try {
        await _service.updateAppointmentStatus(reminderId: r.id, status: newStatus);
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Navega a la página de edición e inicializa el controlador de edición
  /// con la cita seleccionada. Si la edición retorna `true`, recarga la lista.
  Future<void> goEditarCita(AppointmentReminder? r) async {
    // Log para depuración: comprobar si recibimos un reminder válido
    // Esto ayuda a detectar llamadas incorrectas desde la UI
    // ignore: avoid_print
    print('[CITAS] goEditarCita called with reminder == ${r == null ? 'null' : r.id}');

    if (r == null) {
      Get.snackbar('Error', 'No se proporcionó la cita a editar');
      return;
    }

    try {
      // Pasamos la cita como argumento y dejamos que la página de edición
      // cree su propio controller (y lo gestione localmente).
      final edited = await Get.toNamed(HomeRoutes.editarCita, id: 1, arguments: r);
      if (edited == true) {
        await cargar();
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir editor: $e');
    }
  }

  /// Eliminar las citas seleccionadas.
  /// Muestra confirmación y luego llama al servicio.
  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) {
      Get.snackbar('Atención', 'No hay citas seleccionadas');
      return;
    }
    // Esta función sólo ejecuta la eliminación cuando ya se confirmó.
    try {
      cargando.value = true;
      await _service.deleteAppointmentReminders(selectedIds.toList());
      Get.snackbar('Eliminado', 'Citas eliminadas correctamente');
      // Salir del modo selección y recargar
      selectionMode.value = false;
      selectedIds.clear();
      await cargar();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron eliminar: $e');
    } finally {
      cargando.value = false;
    }
  }
}
