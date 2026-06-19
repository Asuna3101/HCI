import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/home_routes.dart';
import 'package:mimedicapp/pages/home/medicacion/editarMedicamento/editarMedicamento_controller.dart';
import '../../../models/medicamentoUsuario.dart';
import '../../../services/medicacion_service.dart';

class MedicacionController extends GetxController {
  final MedicacionService _service = MedicacionService();

  final isLoading = false.obs;

  final medicamentosUsuario = <MedicamentoUsuario>[].obs;
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

  void toggleSelect(MedicamentoUsuario medicamento) {
    final id = medicamento.id;
    if (id == null) return;
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void goToAgregarMedicacion() {
    Get.toNamed(HomeRoutes.agregarMedicamento, id: 1)?.then((result) {
      if (result == true) {
        loadData();
      }
    });
  }

  void goToEditarMedicacion(MedicamentoUsuario medicamento) {
    // Asegurarnos de que el controlador de edición exista e inicializarlo
    final editarCtrl = Get.put(EditarMedicamentoController());
    editarCtrl.initWith(medicamento);

    Get.toNamed(HomeRoutes.editarMedicamento, id: 1, arguments: medicamento)
        ?.then((result) {
      if (result == true) {
        loadData();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final meds = await _service.getMedicamentosUsuario();
      medicamentosUsuario.assignAll(meds);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar los medicamentos seleccionados.
  /// Muestra confirmación y luego llama al servicio.
  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) {
      Get.snackbar('Atención', 'No hay medicamentos seleccionados');
      return;
    }
    // Esta función sólo ejecuta la eliminación cuando ya se confirmó.
    try {
      isLoading.value = true;
      await _service.deleteMedicamentosUsuario(selectedIds.toList());
      Get.snackbar('Eliminado', 'Medicamentos eliminados correctamente');
      // Salir del modo selección y recargar
      selectionMode.value = false;
      selectedIds.clear();
      await loadData();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron eliminar: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
