import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mimedicapp/models/clinic.dart';
import 'package:mimedicapp/models/specialty.dart';
import 'package:mimedicapp/models/doctor.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'cita_form_interface.dart';

/// Controlador para editar una cita existente.
class EditarCitaFormController extends GetxController implements CitaFormInterface {
  EditarCitaFormController(this._service, this.reminder);
  final HealthService _service;
  final AppointmentReminder reminder;

  // combos
  @override
  final clinicas = <Clinic>[].obs;
  @override
  final especialidades = <Specialty>[].obs;
  @override
  final doctores = <Doctor>[].obs;

  @override
  final clinicaSel = Rxn<Clinic>();
  @override
  final especialidadSel = Rxn<Specialty>();
  @override
  final doctorSel = Rxn<Doctor>();

  // fecha/hora + notas
  @override
  final fecha = Rxn<DateTime>();
  @override
  final hora = Rxn<TimeOfDay>();
  @override
  final notasCtrl = TextEditingController();
  @override
  final cargando = false.obs;

  @override
  String get fechaLabel => fecha.value == null
      ? 'Seleccionar fecha'
      : DateFormat('dd/MM/yyyy').format(fecha.value!);

  @override
  String get horaLabel => hora.value == null
      ? 'Seleccionar hora'
      : '${hora.value!.hour.toString().padLeft(2, '0')}:${hora.value!.minute.toString().padLeft(2, '0')}';

  @override
  void resetForm({bool keepCatalogs = true}) {
    clinicaSel.value = null;
    especialidadSel.value = null;
    doctorSel.value = null;

    fecha.value = null;
    hora.value = null;

    notasCtrl.clear();

    if (!keepCatalogs) {
      clinicas.clear();
      especialidades.clear();
      doctores.clear();
    } else {
      especialidades.clear();
      doctores.clear();
    }
  }

  @override
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

  @override
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

  @override
  Future<void> seleccionarFecha() async {
    final hoy = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: fecha.value ?? reminder.startsAt,
      firstDate: hoy,
      lastDate: DateTime(hoy.year + 1),
    );
    if (picked != null) fecha.value = picked;
  }

  @override
  Future<void> seleccionarHora() async {
    final initial = hora.value ?? TimeOfDay.fromDateTime(reminder.startsAt);
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: initial,
    );
    if (picked != null) hora.value = picked;
  }

  @override
  void onClose() {
    notasCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    print('[EDITAR CITA] onInit called for reminder id=${reminder.id}');
    super.onInit();
    _prefill();
  }

  Future<void> _prefill() async {
    try {
      clinicas.assignAll(await _service.getClinics());

      // Selecciona la clínica del reminder si existe en la lista
      final clinicMatch = clinicas.firstWhere(
        (c) => c.id == reminder.clinic.id,
        orElse: () => clinicas.isNotEmpty ? clinicas.first : throw 'No clinics',
      );
      clinicaSel.value = clinicMatch;

      // Cargar especialidades para la clínica y seleccionar
      especialidades.assignAll(await _service.getSpecialties(clinicMatch.id));
      final specMatch = especialidades.firstWhere(
        (s) => s.id == reminder.specialty.id,
        orElse: () => especialidades.isNotEmpty ? especialidades.first : throw 'No specialties',
      );
      especialidadSel.value = specMatch;

      // Cargar doctores y seleccionar
      doctores.assignAll(await _service.getDoctors(clinicMatch.id, specMatch.id));
      final docMatch = doctores.firstWhere(
        (d) => d.id == reminder.doctor.id,
        orElse: () => doctores.isNotEmpty ? doctores.first : throw 'No doctors',
      );
      doctorSel.value = docMatch;

      // Fecha, hora y notas
      fecha.value = DateTime(reminder.startsAt.year, reminder.startsAt.month, reminder.startsAt.day);
      hora.value = TimeOfDay(hour: reminder.startsAt.hour, minute: reminder.startsAt.minute);
      notasCtrl.text = reminder.notes ?? '';
    } catch (e) {
      // Si algo falla, muestra snackbar pero deja la interfaz usable
      Get.snackbar('Error', 'No se pudo prellenar el formulario: $e');
    }
  }

  @override
  Future<void> guardar() async {
    if (cargando.value) return;
    if (clinicaSel.value == null ||
        especialidadSel.value == null ||
        doctorSel.value == null ||
        fecha.value == null ||
        hora.value == null) {
      Get.snackbar('Faltan datos', 'Selecciona clínica, especialidad, médico, fecha y hora');
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
      await _service.updateAppointmentReminder(
        reminderId: reminder.id,
        clinicId: clinicaSel.value!.id,
        specialtyId: especialidadSel.value!.id,
        doctorId: doctorSel.value!.id,
        startsAt: startsAt,
        notes: notasCtrl.text.trim().isEmpty ? null : notasCtrl.text.trim(),
      );

      resetForm();
      Get.back(result: true, id: 1);
      Get.snackbar('Guardado', 'Recordatorio actualizado');
    } catch (e) {
      Get.snackbar('No se pudo guardar', e.toString());
    } finally {
      cargando.value = false;
    }
  }
}
