import 'package:flutter/material.dart';
import 'package:mimedicapp/components/resume_details.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';

Future<void> showCitaDetailsDialog(
  BuildContext context,
  AppointmentReminder a,
) {
  String fmtFecha(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String fmtHora(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m2 = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m2 $ampm';
  }

  final notas = (a.notes == null || a.notes!.trim().isEmpty) ? 'No hay notas' : a.notes!;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(ctx).pop(),
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ResumeDetailsCard(
              title: a.specialty.nombre,
              rows: [
                ResumeRow('Centro de salud', a.clinic.nombre),
                ResumeRow('Doctor', a.doctor.nombre),
                ResumeRow('Fecha', fmtFecha(a.startsAt)),
                ResumeRow('Hora', fmtHora(a.startsAt)),
                ResumeRow('Notas', notas),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
