import 'package:mimedicapp/interfaces/reminder_repository_interface.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';

class UpdateAppointmentStatus {
  final ReminderRepository _repo;
  UpdateAppointmentStatus(this._repo);

  Future<void> call({required int reminderId, required AppointmentStatus status}) =>
      _repo.updateAppointmentStatus(reminderId: reminderId, status: status);
}
