import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/configs/colors.dart';

class UpcomingDueSoonDialog extends StatelessWidget {
  final List<AppointmentReminder> citas;
  const UpcomingDueSoonDialog({super.key, required this.citas});

  String _fmt(DateTime dt) => DateFormat('dd/MM – HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 460),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_filled, color: AppColors.accent, size: 38),
              const SizedBox(height: 8),
              const Text(
                'Citas en los próximos 30 minutos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Titulo',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // listado
              Expanded(
                child: ListView.separated(
                  itemCount: citas.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final c = citas[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                      title: Text('${c.specialty.nombre}  •  ${_fmt(c.startsAt)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Dr./Dra. ${c.doctor.nombre}\n${c.clinic.nombre}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // acciones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(), // cerrar
                      child: const Text('Más tarde'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();                // cierra dialog
                        Get.toNamed('/citas', id: 1); // navega a listado
                      },
                      child: const Text('Ver citas'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
