import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/medicamento.dart';
import 'package:mimedicapp/models/medicamentoUsuario.dart';
import 'package:mimedicapp/models/unidad.dart';
import '../medicamento_form_controller.dart';
import 'package:mimedicapp/services/medicacion_service.dart';

class AgregarMedicamentoController extends GetxController implements MedicamentoFormController {
  final formKey = GlobalKey<FormState>();
  final MedicacionService _service = MedicacionService();

  // Controladores
  final nombreCtrl = TextEditingController();
  final dosisCtrl = TextEditingController();
  final unidadCtrl = TextEditingController();
  final frecuenciaCtrl = TextEditingController();

  // Estado reactivo
  final fechaInicio = Rxn<DateTime>();
  final fechaFin = Rxn<DateTime>();
  final horaInicio = Rxn<TimeOfDay>();

  final medicamentos = <Medicamento>[].obs;
  final unidades = <Unidad>[].obs;

  final isLoading = false.obs;
  final isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();

    // Observa cambios en los campos de texto para validar automáticamente
    nombreCtrl.addListener(_validarFormulario);
    dosisCtrl.addListener(_validarFormulario);
    unidadCtrl.addListener(_validarFormulario);
    frecuenciaCtrl.addListener(_validarFormulario);
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final meds = await _service.getMedicamentos();
      final units = await _service.getUnidades();
      medicamentos.assignAll(meds);
      unidades.assignAll(units);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los datos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Verifica si todos los campos están llenos
  void _validarFormulario() {
    final valid = nombreCtrl.text.trim().isNotEmpty &&
        dosisCtrl.text.trim().isNotEmpty &&
        unidadCtrl.text.trim().isNotEmpty &&
        frecuenciaCtrl.text.trim().isNotEmpty &&
        fechaInicio.value != null &&
        fechaFin.value != null;

    isFormValid.value = valid;
  }

  Future<void> seleccionarFecha({required bool esInicio}) async {
  final hoy = DateTime.now();
  final fecha = await showDatePicker(
    context: Get.context!,
    initialDate: esInicio 
        ? (fechaInicio.value ?? hoy)
        : (fechaFin.value ?? hoy),
    firstDate: hoy,                  // 👈 Bloquea fechas pasadas
    lastDate: DateTime(2100),

    // 👇 Esto bloquea manualmente las fechas anteriores a hoy
    selectableDayPredicate: (day) {
      return !day.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    },
  );

  if (fecha != null) {
    if (esInicio) {
      fechaInicio.value = fecha;
    } else {
      fechaFin.value = fecha;
    }
  }
}

  Future<void> seleccionarHoraInicio() async {
    final seleccionada = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (seleccionada != null) {
      horaInicio.value = seleccionada;
    }
  }

  Future<void> guardar() async {
    if (!isFormValid.value) {
      Get.snackbar(
          'Campos incompletos', 'Completa todos los campos antes de guardar');
      return;
    }

    final hora = horaInicio.value ?? TimeOfDay.now();
    final fechaHoraInicio = DateTime(
      fechaInicio.value!.year,
      fechaInicio.value!.month,
      fechaInicio.value!.day,
      hora.hour,
      hora.minute,
    );

    final nuevo = MedicamentoUsuario(
      id: null,
      nombre: nombreCtrl.text.trim(),
      dosis: double.parse(dosisCtrl.text),
      unidad: unidadCtrl.text.trim(),
      frecuenciaHoras: double.parse(frecuenciaCtrl.text),
      fechaInicio: fechaHoraInicio,
      fechaFin: fechaFin.value!,
    );

    try {
      isLoading.value = true;
      final resultado = await _service.createMedicamentoUsuario(nuevo);

      final mensaje =
          resultado.message ?? 'Medicamento guardado correctamente.';

      resetForm();

      Get.back(result: true, id: 1);
      Get.snackbar(
        'Éxito',
        mensaje,
        backgroundColor: Colors.green[100],
        colorText: AppColors.success,
        icon: const Icon(Icons.check_circle, color: AppColors.success),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red.shade300);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nombreCtrl.dispose();
    dosisCtrl.dispose();
    unidadCtrl.dispose();
    frecuenciaCtrl.dispose();
    super.onClose();
  }
  void resetForm() {
    nombreCtrl.clear();
    dosisCtrl.clear();
    unidadCtrl.clear();
    frecuenciaCtrl.clear();
    fechaInicio.value = null;
    fechaFin.value = null;
    horaInicio.value = null;
    isFormValid.value = false;
  }
}
