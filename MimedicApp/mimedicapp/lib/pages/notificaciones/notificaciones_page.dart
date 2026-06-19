import 'package:flutter/material.dart';
// intl not required in this file (tile handles formatting)
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/notification_item.dart';
// service access moved to controller
import 'package:mimedicapp/pages/notificaciones/notificaciones_controller.dart';
import 'package:mimedicapp/repositories/health_reminder_repository.dart';
import 'package:mimedicapp/repositories/toma_repository.dart';
import 'package:mimedicapp/widgets/notification_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController(repo: HealthReminderRepository(), tomaRepo: TomaRepository());
    _controller.addListener(() => setState(() {}));
    _controller.init();
  }

  @override
  void dispose() {
    _controller.removeListener(() => setState(() {}));
    super.dispose();
  }
  Future<void> _refresh() async => _controller.refresh();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: AppColors.white,
            fontFamily: 'Titulo',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _controller.futureNotifications,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 8),
                  const Text('No se pudieron cargar las notificaciones'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          // use controller's visibleReminders (now NotificationItem)
          final reminders = _controller.visibleReminders;

          if (reminders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('No tienes notificaciones pendientes')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = reminders[i];
                return NotificationTile(
                  item: item,
                  onMarkAttended: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      if (item.source == 'appointment') {
                        await _controller.markAttended(item.id);
                      } else if (item.source == 'toma') {
                        await _controller.markTomado(item.id);
                      } else if (item.source == 'exercise') {
                        await _controller.markEjercicioRealizado(item.id);
                      }
                    } catch (e) {
                      messenger.showSnackBar(const SnackBar(content: Text('No se pudo completar la acción')));
                    }
                  },
                  onDeleteFromView: () async {
                    await _controller.deleteFromView(item.source, item.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Page uses the reusable `NotificationTile` widget from widgets/
