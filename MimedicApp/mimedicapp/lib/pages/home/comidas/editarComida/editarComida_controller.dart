import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/comida.dart';
import 'package:mimedicapp/services/comidas_service.dart';
import '../comida_form_controller.dart';

class EditarComidaController extends GetxController
    implements ComidaFormController {
  @override
  final formKey = GlobalKey<FormState>();
  final ComidasService _service = ComidasService();

  // Controladores
  @override
  final nombreCtrl = TextEditingController();

  @override
  final descripcionCtrl = TextEditingController();

  // Estado reactivo
  @override
  final isLoading = false.obs;

  @override
  final categoriaSeleccionada = Rxn<int>();

  @override
  final categorias = <Map<String, dynamic>>[].obs;

  @override
  final sugerencias = <Map<String, dynamic>>[].obs;

  @override
  final mostrarSugerencias = false.obs;

  // Comida que se está editando
  late Comida comidaOriginal;

  // Debounce timer para búsqueda
  Timer? _debounce;

  @override
  bool get isEditMode => true;

  @override
  void onInit() {
    super.onInit();

    // Agregar listener para búsqueda de sugerencias
    nombreCtrl.addListener(_buscarComidas);

    // Cargar datos iniciales
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final cats = await _service.getCategorias();
      categorias.assignAll(cats);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las categorías: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _buscarComidas() {
    final query = nombreCtrl.text.trim();
    if (query.isEmpty) {
      sugerencias.clear();
      mostrarSugerencias.value = false;
      return;
    }

    // Debounce para evitar muchas peticiones
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        if (query.isNotEmpty) {
          final resultados = await _service.buscarComidas(query);

          sugerencias.assignAll(resultados);
          mostrarSugerencias.value = resultados.isNotEmpty;
        }
      } catch (e) {
        print('Error buscando comidas: $e');
      }
    });
  }

  void initWith(Comida comida) {
    comidaOriginal = comida;
    nombreCtrl.text = comida.nombre;
    descripcionCtrl.text = comida.descripcion ?? '';
    categoriaSeleccionada.value = comida.categoriaId;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    nombreCtrl.removeListener(_buscarComidas);
    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    super.onClose();
  }

  @override
  void seleccionarSugerencia(Map<String, dynamic> sugerencia) {
    nombreCtrl.text = sugerencia['nombre'] as String? ?? '';
    mostrarSugerencias.value = false;
  }

  @override
  Future<void> guardar() async {
    if (!formKey.currentState!.validate()) return;

    if (categoriaSeleccionada.value == null) {
      Get.snackbar('Atención', 'Selecciona si es recomendable o no');
      return;
    }

    try {
      isLoading.value = true;

      await _service.actualizarComida(
        comidaOriginal.id!,
        nombre: nombreCtrl.text.trim(),
        descripcion: descripcionCtrl.text.trim(),
        idCategoria: categoriaSeleccionada.value,
      );

      Get.back(id: 1, result: true);
      Get.snackbar('Éxito', 'Comida actualizada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
