import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/models/notification_item.dart';
import 'package:mimedicapp/widgets/status_badge.dart';

typedef NotificationAction = Future<void> Function();

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final NotificationAction? onMarkAttended;
  final NotificationAction? onDeleteFromView;

  const NotificationTile({
    super.key,
    required this.item,
    this.onMarkAttended,
    this.onDeleteFromView,
  });

  factory NotificationTile.fromAppointment({
    required AppointmentReminder reminder,
    NotificationAction? onMarkAttended,
    NotificationAction? onDeleteFromView,
  }) {
    return NotificationTile(
      item: NotificationItem.fromAppointmentReminder(reminder),
      onMarkAttended: onMarkAttended,
      onDeleteFromView: onDeleteFromView,
    );
  }

  @override
  Widget build(BuildContext context) {
  final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Fecha: ${dateFmt.format(item.startsAt)}'),
                  const SizedBox(height: 4),
                  Text('Notas: ${item.subtitle}'),
                  const SizedBox(height: 8),
                  if (item.status != null)
                    Row(
                      children: [
                        StatusBadge(status: item.status!),
                        const SizedBox(width: 8),
                        if (item.isDueSoon) const Text('¡Próximo!', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                ],
              ),
            ),
            Column(
              children: [
                PopupMenuButton<int>(
                  onSelected: (v) async {
                    if (v == 1 && onMarkAttended != null) {
                      await onMarkAttended!();
                    } else if (v == 2 && onDeleteFromView != null) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Eliminar'),
                          content: const Text('¿Eliminar esta notificación de la vista? (no se borrará en la base de datos)'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
                          ],
                        ),
                      );
                      if (confirm == true) await onDeleteFromView!();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 1,
                      enabled: (item.source == 'toma' || item.source == 'appointment' || item.source == 'exercise'),
                      child: Text(
                        item.source == 'toma'
                          ? 'Marcar como Tomado'
                          : (item.source == 'appointment' 
                              ? 'Marcar como Asistí' 
                              : (item.source == 'exercise' 
                                  ? 'Marcar como Realizado' 
                                  : 'Marcar'))
                      ),
                    ),
                    const PopupMenuItem(value: 2, child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
