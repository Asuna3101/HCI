import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/services/comidas_service.dart';
import '../comida_form_controller.dart';

class AgregarComidaController extends GetxController
    implements ComidaFormController {
  final ComidasService _service = ComidasService();

  @override
  final formKey = GlobalKey<FormState>();

  // Controladores de texto
  @override
  final nombreCtrl = TextEditingController();

  @override
  final descripcionCtrl = TextEditingController();

  // Estado
  @override
  final isLoading = false.obs;

  @override
  final categoriaSeleccionada = Rxn<int>(); // 1=Recomendable, 2=No Recomendable

  @override
  final categorias = <Map<String, dynamic>>[].obs;

  @override
  final sugerencias = <Map<String, dynamic>>[].obs;

  @override
  final mostrarSugerencias = false.obs;

  @override
  bool get isEditMode => false;

  @override
  void onInit() {
    super.onInit();
    cargarCategorias();

    // Listener para búsqueda de comidas
    nombreCtrl.addListener(_buscarComidas);
  }

  @override
  void onClose() {
    nombreCtrl.removeListener(_buscarComidas);
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    super.onClose();
  }

  Future<void> cargarCategorias() async {
    try {
      final cats = await _service.getCategorias();
      categorias.assignAll(cats);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar categorías: $e');
    }
  }

  void _buscarComidas() {
    final query = nombreCtrl.text.trim();
    if (query.isEmpty) {
      sugerencias.clear();
      mostrarSugerencias.value = false;
      return;
    }

    // Debounce - esperar 300ms antes de buscar
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (nombreCtrl.text.trim() == query) {
        try {
          final resultados = await _service.buscarComidas(query);
          print('🔍 Búsqueda "$query": ${resultados.length} resultados');
          sugerencias.assignAll(resultados);
          mostrarSugerencias.value = resultados.isNotEmpty;
          print('📋 Mostrar sugerencias: ${mostrarSugerencias.value}');
        } catch (e) {
          print('❌ Error búsqueda: $e');
          // Silenciar errores de búsqueda
        }
      }
    });
  }

  @override
  void seleccionarSugerencia(Map<String, dynamic> comida) {
    nombreCtrl.text = comida['nombre'] ?? '';
    mostrarSugerencias.value = false;
    sugerencias.clear();
  }

  @override
  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
          'Atención', 'Por favor completa todos los campos obligatorios');
      return;
    }

    if (categoriaSeleccionada.value == null) {
      Get.snackbar('Atención', 'Por favor selecciona una categoría');
      return;
    }

    try {
      isLoading.value = true;

      await _service.registrarComida(
        nombre: nombreCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim().isNotEmpty
            ? descripcionCtrl.text.trim()
            : null,
        idCategoria: categoriaSeleccionada.value,
      );

      Get.back(id: 1); // Regresar a la lista de comidas
      Get.snackbar('Éxito', 'Comida registrada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo guardar la comida: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
