import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/medicamentoUsuario.dart';
import 'package:mimedicapp/models/medicamento.dart';
import 'package:mimedicapp/models/unidad.dart';
import 'package:mimedicapp/services/medicacion_service.dart';
import '../medicamento_form_controller.dart';

class EditarMedicamentoController extends GetxController implements MedicamentoFormController {
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

  final isLoading = false.obs;
  final isFormValid = false.obs;

  // Medicamento que se está editando (nullable hasta que se inicialice)
  MedicamentoUsuario? medicamentoOriginal;

  // Listas que pueden mostrar autocompletados (reutilizamos el servicio)
  final RxList<Medicamento> medicamentos = <Medicamento>[].obs;
  final RxList<Unidad> unidades = <Unidad>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();

    // Si se pasó el medicamento por Get.arguments, inicializamos
    final arg = Get.arguments;
    print('✳️ EditarMedicamentoController.onInit - Get.arguments: $arg');
    if (arg is MedicamentoUsuario) {
      initWith(arg);
    }
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

  // Inicializar con el medicamento pasado por Get.arguments o constructor
  void initWith(MedicamentoUsuario medicamento) {
    print('✳️ EditarMedicamentoController.initWith id=${medicamento.id}');
    medicamentoOriginal = medicamento;
    nombreCtrl.text = medicamento.nombre;
    dosisCtrl.text = medicamento.dosis.toString();
    unidadCtrl.text = medicamento.unidad;
    frecuenciaCtrl.text = medicamento.frecuenciaHoras.toString();
    fechaInicio.value = medicamento.fechaInicio;
    fechaFin.value = medicamento.fechaFin;
    horaInicio.value = TimeOfDay(
      hour: medicamento.fechaInicio.hour,
      minute: medicamento.fechaInicio.minute,
    );

    // Listeners para validación
    nombreCtrl.addListener(_validarFormulario);
    dosisCtrl.addListener(_validarFormulario);
    unidadCtrl.addListener(_validarFormulario);
    frecuenciaCtrl.addListener(_validarFormulario);

    _validarFormulario();
  }

  @override
  void onClose() {
    nombreCtrl.dispose();
    dosisCtrl.dispose();
    unidadCtrl.dispose();
    frecuenciaCtrl.dispose();
    super.onClose();
  }

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
    final seleccionada = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (seleccionada != null) {
      if (esInicio) {
        fechaInicio.value = seleccionada;
      } else {
        fechaFin.value = seleccionada;
      }
      _validarFormulario();
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
    print('✳️ guardarCambios called - medicamentoOriginal?.id=${medicamentoOriginal?.id}');
    if (!isFormValid.value) {
      Get.snackbar('Campos incompletos', 'Completa todos los campos antes de guardar');
      return;
    }

    final dosis = double.tryParse(dosisCtrl.text.trim());
    final frecuencia = double.tryParse(frecuenciaCtrl.text.trim());

    if (dosis == null || frecuencia == null) {
      Get.snackbar('Error de formato', 'Dosis o frecuencia no válidas');
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

    // Asegurarnos de que exista un medicamento original con id
    if (medicamentoOriginal == null || medicamentoOriginal!.id == null) {
      Get.snackbar('Error', 'No se encontró el medicamento a editar');
      return;
    }

    final actualizado = MedicamentoUsuario(
      id: medicamentoOriginal!.id,
      nombre: nombreCtrl.text.trim(),
      dosis: dosis,
      unidad: unidadCtrl.text.trim(),
      frecuenciaHoras: frecuencia,
      fechaInicio: fechaHoraInicio,
      fechaFin: fechaFin.value!,
    );

    try {
      isLoading.value = true;
      final resultado = await _service.updateMedicamentoUsuario(actualizado.id!, actualizado);

      final mensaje = resultado.message ?? 'Medicamento actualizado correctamente.';

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
