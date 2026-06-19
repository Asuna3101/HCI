import 'package:mimedicapp/interfaces/reminder_repository_interface.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/services/health_service.dart';

class HealthReminderRepository implements ReminderRepository {
  final HealthService _health;
  HealthReminderRepository([HealthService? health]) : _health = health ?? HealthService();

  @override
  Future<List<AppointmentReminder>> getUpcomingReminders() => _health.getUpcomingReminders();

  @override
  Future<void> updateAppointmentStatus({required int reminderId, required AppointmentStatus status}) =>
      _health.updateAppointmentStatus(reminderId: reminderId, status: status);
}
