// lib/pages/home/citas/formulario_cita_medica/crear_cita_form_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mimedicapp/models/clinic.dart';
import 'package:mimedicapp/models/specialty.dart';
import 'package:mimedicapp/models/doctor.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'cita_form_interface.dart';

class AgregarCitaFormController extends GetxController implements CitaFormInterface {
  AgregarCitaFormController(this._service);
  final HealthService _service;

  // combos
  final clinicas = <Clinic>[].obs;
  final especialidades = <Specialty>[].obs;
  final doctores = <Doctor>[].obs;

  final clinicaSel = Rxn<Clinic>();
  final especialidadSel = Rxn<Specialty>();
  final doctorSel = Rxn<Doctor>();

  // fecha/hora + notas
  final fecha = Rxn<DateTime>();
  final hora = Rxn<TimeOfDay>();
  final notasCtrl = TextEditingController();
  final cargando = false.obs;

  String get fechaLabel => fecha.value == null
      ? 'Seleccionar fecha'
      : DateFormat('dd/MM/yyyy').format(fecha.value!);

  String get horaLabel => hora.value == null
      ? 'Seleccionar hora'
      : '${hora.value!.hour.toString().padLeft(2, '0')}:${hora.value!.minute.toString().padLeft(2, '0')}';

  @override
  void onInit() {
    print('[AGREGAR CITA] onInit called for reminder');
    super.onInit();
    _loadClinics();
  }

  /// 🔄 Limpia el estado del formulario.
  /// keepCatalogs=true mantiene los catálogos en memoria.
  void resetForm({bool keepCatalogs = true}) {
    // Selecciones
    clinicaSel.value = null;
    especialidadSel.value = null;
    doctorSel.value = null;

    // Fechas y hora
    fecha.value = null;
    hora.value = null;

    // Notas
    notasCtrl.clear();

    // Limpiar listas dependientes
    if (!keepCatalogs) {
      clinicas.clear();
      especialidades.clear();
      doctores.clear();
    } else {
      // Si mantengo catálogos, al menos vacío las dependencias para que no queden valores colgados
      especialidades.clear();
      doctores.clear();
    }
  }

  Future<void> _loadClinics() async {
    try {
      clinicas.assignAll(await _service.getClinics());
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar clínicas: $e');
    }
  }

  Future<void> onClinicaChanged(Clinic? c) async {
    clinicaSel.value = c;
    especialidadSel.value = null;
    doctorSel.value = null;
    especialidades.clear();
    doctores.clear();
    if (c != null) {
      try {
        especialidades.assignAll(await _service.getSpecialties(c.id));
      } catch (e) {
        Get.snackbar('Error', 'No se pudieron cargar especialidades: $e');
      }
    }
  }

  Future<void> onEspecialidadChanged(Specialty? s) async {
    especialidadSel.value = s;
    doctorSel.value = null;
    doctores.clear();
    if (s != null && clinicaSel.value != null) {
      try {
        doctores.assignAll(await _service.getDoctors(clinicaSel.value!.id, s.id));
      } catch (e) {
        Get.snackbar('Error', 'No se pudieron cargar médicos: $e');
      }
    }
  }

  Future<void> seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: fecha.value ?? hoy,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1),
    );
    if (picked != null) fecha.value = picked;
  }

  Future<void> seleccionarHora() async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: hora.value ?? TimeOfDay.now(),
    );
    if (picked != null) hora.value = picked;
  }

  Future<void> guardar() async {
    if (cargando.value) return;
    if (clinicaSel.value == null ||
        especialidadSel.value == null ||
        doctorSel.value == null ||
        fecha.value == null ||
        hora.value == null) {
      Get.snackbar('Faltan datos',
          'Selecciona clínica, especialidad, médico, fecha y hora');
      return;
    }

    final startsAt = DateTime(
      fecha.value!.year,
      fecha.value!.month,
      fecha.value!.day,
      hora.value!.hour,
      hora.value!.minute,
    );

    cargando.value = true;
    try {
      await _service.createAppointmentReminder(
        clinicId: clinicaSel.value!.id,
        specialtyId: especialidadSel.value!.id,
        doctorId: doctorSel.value!.id,
        startsAt: startsAt,
        notes: notasCtrl.text.trim().isEmpty ? null : notasCtrl.text.trim(),
      );
      // Limpia después de guardar por si el usuario vuelve a abrir la pantalla
      resetForm();
      Get.back(result: true, id: 1);
      Get.snackbar('Guardado', 'Recordatorio creado');
    } catch (e) {
      Get.snackbar('No se pudo guardar', e.toString());
    } finally {
      cargando.value = false;
    }
  }

  @override
  void onClose() {
    notasCtrl.dispose();
    super.onClose();
  }
}