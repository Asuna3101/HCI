import 'package:flutter/material.dart';
import 'package:mimedicapp/components/resume_details.dart';
import 'package:mimedicapp/models/medicamentoUsuario.dart';


Future<void> showMedicineDetailsDialog(
  BuildContext context,
  MedicamentoUsuario m,
) {
  String fmtFecha(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String fmtHora(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m2 = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m2 $ampm';
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
              title: m.nombre,
              rows: [
                ResumeRow('Dosis', '${m.dosis} ${m.unidad}'),
                ResumeRow('Primera toma', fmtHora(m.fechaInicio)),
                ResumeRow('Repetición', 'Cada ${m.frecuenciaHoras.toStringAsFixed(0)}h'),
                ResumeRow('Inicio', fmtFecha(m.fechaInicio)),
                ResumeRow('Fin', fmtFecha(m.fechaFin)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
