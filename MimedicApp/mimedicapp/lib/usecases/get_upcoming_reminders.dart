import 'package:mimedicapp/interfaces/reminder_repository_interface.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';

class GetUpcomingReminders {
  final ReminderRepository _repo;
  GetUpcomingReminders(this._repo);

  Future<List<AppointmentReminder>> call() => _repo.getUpcomingReminders();
}
