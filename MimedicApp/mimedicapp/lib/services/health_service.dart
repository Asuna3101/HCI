// lib/services/health_service.dart
import 'package:mimedicapp/services/api_service.dart';
import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/models/clinic.dart';
import 'package:mimedicapp/models/specialty.dart';
import 'package:mimedicapp/models/doctor.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';

class HealthService {
  HealthService([ApiService? api]) : _api = api ?? ApiService();
  final ApiService _api;

  // ---------- Catálogos ----------
  Future<List<Clinic>> getClinics() async {
    final data = await _api.get(ApiConfig.clinics(), auth: true);
    return (data as List).map((e) => Clinic.fromJson(e)).toList();
  }

  Future<List<Specialty>> getSpecialties(int clinicId) async {
    final data = await _api.get(ApiConfig.specialties(clinicId), auth: true);
    return (data as List).map((e) => Specialty.fromJson(e)).toList();
  }

  Future<List<Doctor>> getDoctors(int clinicId, int specialtyId) async {
    final data = await _api.get(ApiConfig.doctors(clinicId, specialtyId), auth: true);
    return (data as List).map((e) => Doctor.fromJson(e)).toList();
  }

  // ---------- Citas ----------
  Future<AppointmentReminder> createAppointmentReminder({
    required int clinicId,
    required int specialtyId,
    required int doctorId,
    required DateTime startsAt,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'clinic_id': clinicId,
      'specialty_id': specialtyId,
      'doctor_id': doctorId,
      'starts_at': startsAt.toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final data = await _api.post(ApiConfig.appointmentReminders(), payload, auth: true);
    return AppointmentReminder.fromJson(data as Map<String, dynamic>);
  }

  /// Actualiza una cita existente usando el endpoint PUT /update/{reminder_id}
  Future<AppointmentReminder> updateAppointmentReminder({
    required int reminderId,
    required int clinicId,
    required int specialtyId,
    required int doctorId,
    required DateTime startsAt,
    String? notes,
  }) async {
    final payload = <String, dynamic>{
      'clinic_id': clinicId,
      'specialty_id': specialtyId,
      'doctor_id': doctorId,
      'starts_at': startsAt.toIso8601String(),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final endpoint = '${ApiConfig.appointmentReminders()}/update/$reminderId';
    final data = await _api.put(endpoint, payload, auth: true);
    return AppointmentReminder.fromJson(data as Map<String, dynamic>);
  }

  // Endpoints alineados al backend
  Future<List<AppointmentReminder>> getUpcomingReminders() async {
    final data = await _api.get('${ApiConfig.appointmentReminders()}/upcoming', auth: true);
    return (data as List).map((e) => AppointmentReminder.fromJson(e)).toList();
  }

  Future<List<AppointmentReminder>> getHistoryReminders() async {
    final data = await _api.get('${ApiConfig.appointmentReminders()}/history', auth: true);
    return (data as List).map((e) => AppointmentReminder.fromJson(e)).toList();
  }

  Future<void> updateAppointmentStatus({
    required int reminderId,
    required AppointmentStatus status,
  }) async {
    await _api.patch(
      '${ApiConfig.appointmentReminders()}/$reminderId/status',
      {'status': statusToString(status)},
      auth: true,
    );
  }

  /// Elimina múltiples recordatorios de cita usando el endpoint POST /delete
  Future<void> deleteAppointmentReminders(List<int> reminderIds) async {
    if (reminderIds.isEmpty) return;
    final payload = <String, dynamic>{'reminder_ids': reminderIds};
    await _api.post('${ApiConfig.appointmentReminders()}/delete', payload, auth: true);
  }
}
