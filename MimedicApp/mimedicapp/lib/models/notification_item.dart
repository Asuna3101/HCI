import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/models/toma.dart';
import 'package:mimedicapp/models/status.dart';

class NotificationItem {
  final int id;
  final String title;
  final String subtitle;
  final DateTime startsAt;
  final Status? status;
  final bool isDueSoon;
  final String source; // e.g. 'appointment', 'medication'
  final dynamic payload;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startsAt,
    this.status,
    this.isDueSoon = false,
    this.source = 'unknown',
    this.payload,
  });

  factory NotificationItem.fromAppointmentReminder(AppointmentReminder r) =>
      NotificationItem(
        id: r.id,
        title: 'Cita con ${r.doctor.nombre}',
        subtitle: r.notes ?? '-',
        startsAt: r.startsAt,
        status: r.status,
        isDueSoon: r.isDueSoon,
        source: 'appointment',
        payload: r,
      );

  factory NotificationItem.fromToma(Toma t) => NotificationItem(
        id: t.id,
        title: 'Toma: ${t.medicamentoNombre}',
        subtitle: '${t.dosis} ${t.unidad}',
        startsAt: t.adquired.toLocal(),
        status: null,
        isDueSoon: true,
        source: 'toma',
        payload: t,
      );

  factory NotificationItem.fromEjercicio(EjercicioUsuario e) {
    Status? ejercicioStatus;
    if (e.realizado == false) {
      final now = DateTime.now();
      final horarioDateTime = _parseHorario(e.horario);
      
      if (horarioDateTime.isBefore(now)) {
        ejercicioStatus = EjercicioStatus.noRealizado;
      } else {
        ejercicioStatus = EjercicioStatus.pendiente;
      }
    }
    
    return NotificationItem(
      id: e.id!,
      title: 'Ejercicio',
      subtitle: e.nombre ?? '',
      startsAt: _parseHorario(e.horario),
      status: ejercicioStatus,
      isDueSoon: false,
      source: 'exercise',
      payload: e,
    );
  }

  static DateTime _parseHorario(String? hhmm) {
    if (hhmm == null || hhmm.length < 5) return DateTime.now();
    final parts = hhmm.split(':');
    final now = DateTime.now();
    return DateTime(
        now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
