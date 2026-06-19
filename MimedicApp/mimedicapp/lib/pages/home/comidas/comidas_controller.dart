import 'package:get/get.dart';
import 'package:mimedicapp/models/comida.dart';
import 'package:mimedicapp/services/comidas_service.dart';
import 'package:mimedicapp/pages/home/comidas/editarComida/editarComida_controller.dart';

class ComidasController extends GetxController {
  final ComidasService _service = ComidasService();

  final isLoading = false.obs;
  final comidas = <Comida>[].obs;
  final selectionMode = false.obs;
  final selectedIds = <int>[].obs;

  void toggleSelectionMode() {
    selectionMode.value = !selectionMode.value;
    if (!selectionMode.value) selectedIds.clear();
  }

  void toggleSelect(Comida c) {
    final id = c.id;
    if (id == null) return;
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final items = await _service.getComidasUsuario();
      comidas.assignAll(items);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar comidas: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) {
      Get.snackbar('Atención', 'No hay comidas seleccionadas');
      return;
    }
    try {
      isLoading.value = true;
      await _service.eliminarComidas(selectedIds.toList());
      Get.snackbar('Eliminado', 'Comidas eliminadas correctamente');
      selectionMode.value = false;
      selectedIds.clear();
      await loadData();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron eliminar: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToAgregarComida() {
    Get.toNamed('/home/comidas/agregar', id: 1)?.then((_) => loadData());
  }

  void goToEditarComida(Comida comida) {
    final editarCtrl = Get.put(EditarComidaController());
    editarCtrl.initWith(comida);

    Get.toNamed('/home/comidas/editar', id: 1, arguments: comida)
        ?.then((_) => loadData());
  }
}
