import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/ejercicio.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_form_controller.dart';
import 'package:mimedicapp/services/ejercicio_service.dart';
import 'package:mimedicapp/configs/colors.dart';

class EditarEjercicioUsuarioController extends GetxController
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

  late EjercicioUsuario ejercicioOriginal;

  // ===========================================================
  // initWith -> se llama desde EjercicioController
  // ===========================================================
  void initWith(EjercicioUsuario e) {
    ejercicioOriginal = e;

    nombreCtrl.text = e.nombre ?? '';
    notasCtrl.text = e.notas ?? '';
    duracionCtrl.text = e.duracionMin?.toString() ?? '';

    if (e.horario != null && e.horario!.contains(':')) {
      final parts = e.horario!.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      hora.value = TimeOfDay(hour: h, minute: m);
    }

    _validarFormulario();
  }

  @override
  void onInit() {
    super.onInit();
    _loadCatalogo();

    nombreCtrl.addListener(_validarFormulario);
    notasCtrl.addListener(_validarFormulario);
    duracionCtrl.addListener(_validarFormulario);
  }

  // ===========================================================
  // Cargar catálogo
  // ===========================================================
  Future<void> _loadCatalogo() async {
    try {
      isLoading.value = true;
      final lista = await _service.getEjercicios();
      ejercicios.assignAll(lista);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar catálogo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================
  // Validaciones
  // ===========================================================
  void _validarFormulario() {
    if (nombreCtrl.text.trim().isEmpty) {
      isFormValid.value = false;
      return;
    }

    final dur = int.tryParse(duracionCtrl.text);
    if (dur == null || dur <= 0) {
      isFormValid.value = false;
      return;
    }

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
      initialTime: hora.value ?? TimeOfDay.now(),
    );

    if (seleccion != null) {
      hora.value = seleccion;
      _validarFormulario();
    }
  }

  // ===========================================================
  // Guardar cambios (solo los campos alterados)
  // ===========================================================
  @override
  Future<void> guardar() async {
    if (!isFormValid.value) {
      Get.snackbar(
        'Campos incompletos',
        'Completa todos los campos y selecciona una hora.',
      );
      return;
    }
    final h = hora.value!;
    final horaStr =
        "${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}";
    final actualizado = EjercicioUsuario(
      id: ejercicioOriginal.id,
      nombre: nombreCtrl.text.trim() != (ejercicioOriginal.nombre ?? "")
          ? nombreCtrl.text.trim()
          : null,
      notas: notasCtrl.text.trim() != (ejercicioOriginal.notas ?? "")
          ? notasCtrl.text.trim()
          : null,
      duracionMin:
          int.parse(duracionCtrl.text.trim()) != ejercicioOriginal.duracionMin
              ? int.parse(duracionCtrl.text.trim())
              : null,
      horario: horaStr != ejercicioOriginal.horario ? horaStr : null,
    );
    try {
      isLoading.value = true;
      await _service.updateEjercicioUsuario(
        ejercicioOriginal.id!,
        actualizado,
      );
      Get.back(result: true, id: 1);
      Get.snackbar(
        'Éxito',
        'Ejercicio actualizado correctamente.',
        backgroundColor: Colors.green[100],
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle, color: AppColors.success),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red.shade300);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nombreCtrl.dispose();
    notasCtrl.dispose();
    duracionCtrl.dispose();
    super.onClose();
  }
}