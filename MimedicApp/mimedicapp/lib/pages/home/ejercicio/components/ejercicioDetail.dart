import 'package:flutter/material.dart';
import 'package:mimedicapp/components/resume_details.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';

Future<void> showEjercicioDetailsDialog(
  BuildContext context,
  EjercicioUsuario e,
) {
  String fmtHora(String? raw) {
    if (raw == null) return '';
    final parts = raw.split(':');
    if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
    return raw;
  }

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
              title: e.nombre ?? '',
              rows: [
                ResumeRow('Horario', fmtHora(e.horario)),
                ResumeRow(
                  'Duración',
                  '${e.duracionMin ?? 0} min',
                ),
                ResumeRow(
                  'Descripción',
                  e.notas?.isNotEmpty == true ? e.notas! : '—',
                ),
                ResumeRow(
                  'Estado',
                  e.realizado == true ? 'Realizado' : 'Pendiente',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}