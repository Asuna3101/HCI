import 'package:mimedicapp/models/status.dart';
export 'package:mimedicapp/models/status.dart' show AppointmentStatus, statusFromString, statusToString;

// lib/models/appointment_reminder.dart
class ClinicMini {
  final int id;
  final String nombre;
  ClinicMini({required this.id, required this.nombre});
  factory ClinicMini.fromJson(Map<String, dynamic> j) =>
      ClinicMini(id: j['id'] as int, nombre: j['nombre'] as String);
}

class SpecialtyMini {
  final int id;
  final String nombre;
  SpecialtyMini({required this.id, required this.nombre});
  factory SpecialtyMini.fromJson(Map<String, dynamic> j) =>
      SpecialtyMini(id: j['id'] as int, nombre: j['nombre'] as String);
}

class DoctorMini {
  final int id;
  final String nombre;
  DoctorMini({required this.id, required this.nombre});
  factory DoctorMini.fromJson(Map<String, dynamic> j) =>
      DoctorMini(id: j['id'] as int, nombre: j['nombre'] as String);
}

class AppointmentReminder {
  final int id;
  final DateTime startsAt;
  final String? notes;
  final ClinicMini clinic;
  final SpecialtyMini specialty;
  final DoctorMini doctor;
  final AppointmentStatus status;
  final bool isDueSoon;

  AppointmentReminder({
    required this.id,
    required this.startsAt,
    required this.notes,
    required this.clinic,
    required this.specialty,
    required this.doctor,
    required this.status,
    required this.isDueSoon,
  });

  factory AppointmentReminder.fromJson(Map<String, dynamic> j) => AppointmentReminder(
    id: j['id'] as int,
    startsAt: DateTime.parse(j['starts_at'] as String).toLocal(),
    notes: j['notes'] as String?,
    clinic: ClinicMini.fromJson(j['clinic'] as Map<String, dynamic>),
    specialty: SpecialtyMini.fromJson(j['specialty'] as Map<String, dynamic>),
    doctor: DoctorMini.fromJson(j['doctor'] as Map<String, dynamic>),
    status: statusFromString((j['status'] as String?) ?? 'PENDIENTE'),
    isDueSoon: (j['is_due_soon'] as bool?) ?? false,
  );
}
