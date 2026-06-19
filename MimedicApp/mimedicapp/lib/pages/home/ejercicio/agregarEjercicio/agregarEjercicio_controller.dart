import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/ejercicio.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_form_controller.dart';
import 'package:mimedicapp/services/ejercicio_service.dart';
import 'package:mimedicapp/configs/colors.dart';

class AgregarEjercicioUsuarioController extends GetxController
    implements EjercicioUsuarioFormController {
  final formKey = GlobalKey<FormState>();

  final EjercicioService _service = EjercicioService();

  // Inputs
  final nombreCtrl = TextEditingController();
  final notasCtrl = TextEditingController();
  final duracionCtrl = TextEditingController();

  // Hora seleccionada
  final hora = Rxn<TimeOfDay>();

  // Catálogo
  final ejercicios = <Ejercicio>[].obs;

  // Estados
  final isLoading = false.obs;
  final isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCatalogo();

    nombreCtrl.addListener(_validarFormulario);
    notasCtrl.addListener(_validarFormulario);
    duracionCtrl.addListener(_validarFormulario);
  }

  // ==========================
  // Cargar catálogo
  // ==========================
  Future<void> _loadCatalogo() async {
    try {
      isLoading.value = true;
      final lista = await _service.getEjercicios();
      ejercicios.assignAll(lista);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el catálogo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================
  // Validaciones
  // ==========================
  void _validarFormulario() {
    // Nombre
    if (nombreCtrl.text.trim().isEmpty) {
      isFormValid.value = false;
      return;
    }

    // Duración
    final dur = int.tryParse(duracionCtrl.text);
    if (dur == null || dur <= 0) {
      isFormValid.value = false;
      return;
    }

    // Hora
    if (hora.value == null) {
      isFormValid.value = false;
      return;
    }

    isFormValid.value = true;
  }

  @override
  Future<void> seleccionarHora() async {
    final seleccion = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (seleccion != null) {
      hora.value = seleccion;
      _validarFormulario();
    }
  }

  // ==========================
  // Guardar
  // ==========================
  @override
  Future<void> guardar() async {
    if (!isFormValid.value) {
      Get.snackbar('Campos incompletos',
          'Completa todos los campos y asegúrate de seleccionar una hora.');
      return;
    }

    final h = hora.value!;
    final horaStr =
        "${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}:00";

    final nuevo = EjercicioUsuario(
        nombre: nombreCtrl.text.trim(),
        notas: notasCtrl.text.trim(),
        duracionMin: int.parse(duracionCtrl.text.trim()),
        horario: horaStr,
        realizado: false);

    try {
      isLoading.value = true;
      await _service.createEjercicioUsuario(nuevo);

      resetForm();
      Get.back(result: true, id: 1);

      Get.snackbar(
        'Éxito',
        'Ejercicio registrado correctamente.',
        backgroundColor: Colors.green[100],
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle, color: AppColors.success),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade300);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    resetForm();
    nombreCtrl.dispose();
    notasCtrl.dispose();
    duracionCtrl.dispose();
    super.onClose();
  }

  void resetForm() {
    nombreCtrl.clear();
    notasCtrl.clear();
    duracionCtrl.clear();
    hora.value = null;
    isFormValid.value = false;
  }
}
