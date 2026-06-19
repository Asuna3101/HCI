import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/widgets/status_badge.dart';
import 'package:mimedicapp/pages/home/citas/components/cita_details.dart';

class CitaMedicaCard extends StatelessWidget {
  final AppointmentReminder cita;
  final VoidCallback? onEdit;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelect;

  const CitaMedicaCard({
    super.key,
    required this.cita,
    this.onEdit,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggleSelect,
  });

  String _formatFecha(DateTime fecha) {
    final meses = [
      "enero","febrero","marzo","abril","mayo","junio",
      "julio","agosto","septiembre","octubre","noviembre","diciembre"
    ];
    final mes = meses[fecha.month - 1];
    final hora = "${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
    return "${fecha.day} de $mes $hora";
  }

    @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.getButtonColor(context).withOpacity(0.35),
              width: 0.8,
            ),
          ),
          elevation: 0.5,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showCitaDetailsDialog(context, cita),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cita.specialty.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge solo visual
                    StatusBadge(status: cita.status, compact: true),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_formatFecha(cita.startsAt),
                    style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("Dr. / Dra. ${cita.doctor.nombre}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(cita.clinic.nombre,
                    style: const TextStyle(fontSize: 16, color: Colors.black87)),
                if (cita.notes != null && cita.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(cita.notes!,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black54)),
                ],
              ],
            ),
          ),
        ),
        ),
        // Lapiz
        Positioned(
          top: -12,
          right: -8,
          child: IconButton(
            tooltip: 'Editar (pronto)',
            icon: Icon(Icons.edit,
                color: AppColors.getButtonColor(context), size: 26),
            onPressed: onEdit ?? () {},
          ),
        ),

        // Check de selección (opcional)
        if (selectionMode)
          Positioned(
            top: -18,
            left: -18,
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                elevation: MaterialStateProperty.all(2),
              ),
              icon: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? AppColors.primary : AppColors.grey400,
                size: 26,
              ),
              onPressed: onToggleSelect,
            ),
          ),
      ],
    );
  }

}
