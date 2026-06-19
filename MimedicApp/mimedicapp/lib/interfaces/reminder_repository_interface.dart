import 'package:mimedicapp/models/appointment_reminder.dart';

abstract class ReminderRepository {
  Future<List<AppointmentReminder>> getUpcomingReminders();
  Future<void> updateAppointmentStatus({required int reminderId, required AppointmentStatus status});
}
