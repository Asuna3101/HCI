import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/ejercicioUsuario.dart';
import 'package:mimedicapp/pages/container/container_controller.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_controller.dart';
import 'package:mimedicapp/services/ejercicio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/models/notification_item.dart';
import 'package:mimedicapp/utils/event_bus.dart';
import 'package:mimedicapp/interfaces/reminder_repository_interface.dart';
import 'package:mimedicapp/repositories/toma_repository.dart';
import 'package:mimedicapp/usecases/get_upcoming_reminders.dart';
import 'package:mimedicapp/usecases/update_appointment_status.dart';

class NotificationsController extends ChangeNotifier {
  final ReminderRepository _repo;
  final TomaRepository? _tomaRepo;
  late final GetUpcomingReminders _getUpcoming;
  late final UpdateAppointmentStatus _updateStatus;

  /// Este controller ahora expone una lista combinada de notificaciones
  /// (citas y tomas). Se usa una clave compuesta `"<source>_<id>"` para
  /// identificar de forma única cada notificación en caches y prefs.
  NotificationsController(
      {required ReminderRepository repo, TomaRepository? tomaRepo})
      : _repo = repo,
        _tomaRepo = tomaRepo {
    _getUpcoming = GetUpcomingReminders(_repo);
    _updateStatus = UpdateAppointmentStatus(_repo);
    // initialize and subscribe to toma events to update UI in real-time
    futureNotifications = _loadNotifications();
    EventBus().stream.listen((e) {
      try {
        if (e['type'] == 'toma_event') {
          // add a visible notification for the toma event
          final key = _keyFor('toma_event',
              (e['tomaId'] as int?) ?? DateTime.now().millisecondsSinceEpoch);
          final startsAt = e['timestamp'] is String
              ? DateTime.parse(e['timestamp']).toLocal()
              : DateTime.now();
          final title = e['action'] == 'tomado'
              ? 'Toma marcada como Tomado'
              : (e['action'] == 'postponed' ? 'Toma pospuesta' : 'Toma');
          final subtitle = (e['medicamentoNombre'] != null)
              ? '${e['medicamentoNombre']} - ${e['dosis'] ?? ''} ${e['unidad'] ?? ''}'
              : '${e['action'] ?? ''}';
          final item = NotificationItem(
            id: (e['tomaId'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
            title: title,
            subtitle: subtitle,
            startsAt: startsAt,
            status: null,
            isDueSoon: false,
            source: 'toma_event',
            payload: e,
          );
          _cachedNotifications[key] = item;
          _seenPendingKeys.add(key);
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  late Future<List<NotificationItem>> futureNotifications;

  final Set<String> _dismissedKeys = <String>{};
  final Set<String> _seenPendingKeys = <String>{};
  final Map<String, NotificationItem> _cachedNotifications = {};

  String _keyFor(String source, int id) => '$source\_$id';

  // expose read-only views
  List<NotificationItem> get visibleReminders {
    final list = _cachedNotifications.values.where((r) {
      final key = _keyFor(r.source, r.id);
      if (_dismissedKeys.contains(key)) return false;
      // For appointments, treat pendiente specially via status
      if (r.source == 'appointment' && r.status == AppointmentStatus.pendiente)
        return true;
      if (_seenPendingKeys.contains(key)) return true;
      return false;
    }).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  Future<List<NotificationItem>> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed =
        prefs.getStringList('notificaciones_dismissed_ids') ?? <String>[];
    final seen =
        prefs.getStringList('notificaciones_seen_pending_ids') ?? <String>[];
    _dismissedKeys.clear();
    _dismissedKeys.addAll(dismissed);
    _seenPendingKeys.clear();
    _seenPendingKeys.addAll(seen);
    _cachedNotifications.clear();

    // fetch appointments
    final appts = await _getUpcoming.call();
    for (final a in appts) {
      final item = NotificationItem.fromAppointmentReminder(a);
      final key = _keyFor(item.source, item.id);
      _cachedNotifications[key] = item;
      if (a.status == AppointmentStatus.pendiente) _seenPendingKeys.add(key);
    }

    // fetch pending tomas (if repo provided)
    if (_tomaRepo != null) {
      try {
        final now = DateTime.now().toUtc();
        final tomas = await _tomaRepo.getPendingTomas(at: now);
        for (final t in tomas) {
          final item = NotificationItem.fromToma(t);
          final key = _keyFor(item.source, item.id);
          _cachedNotifications[key] = item;
          _seenPendingKeys.add(key);
        }
      } catch (e) {
        // ignore toma errors; appointments are primary here
      }
    }

    try {
      final ejercicios = await EjercicioService().getEjerciciosUsuario();

      for (final e in ejercicios) {
        if (e.realizado != true) {
          final item = NotificationItem.fromEjercicio(e);
          final key = _keyFor('exercise', e.id!);
          _cachedNotifications[key] = item;
          _seenPendingKeys.add(key);
        }
      }
    } catch (_) {}

    await prefs.setStringList(
        'notificaciones_seen_pending_ids', _seenPendingKeys.toList());
    await prefs.setStringList(
        'notificaciones_dismissed_ids', _dismissedKeys.toList());

    notifyListeners();
    return _cachedNotifications.values.toList();
  }

  Future<void> init() async {
    futureNotifications = _loadNotifications();
  }

  Future<void> refresh() async {
    futureNotifications = _loadNotifications();
  }

  Future<void> markAttended(int reminderId) async {
    // Appointment-specific action
    await _updateStatus.call(
        reminderId: reminderId, status: AppointmentStatus.asistido);
    final key = _keyFor('appointment', reminderId);
    final cached = _cachedNotifications[key];
    if (cached != null && cached.payload is AppointmentReminder) {
      final a = cached.payload as AppointmentReminder;
      final updated = AppointmentReminder(
        id: a.id,
        startsAt: a.startsAt,
        notes: a.notes,
        clinic: a.clinic,
        specialty: a.specialty,
        doctor: a.doctor,
        status: AppointmentStatus.asistido,
        isDueSoon: a.isDueSoon,
      );
      _cachedNotifications[key] =
          NotificationItem.fromAppointmentReminder(updated);
    }
    notifyListeners();
  }

  Future<void> markTomado(int tomaId) async {
    if (_tomaRepo == null) return;
    await _tomaRepo.markTomado(tomaId, true);
    // create an event notification so user sees it in the list
    final timestamp = DateTime.now();
    final eventKey =
        _keyFor('toma_event', DateTime.now().millisecondsSinceEpoch);
    final item = NotificationItem(
      id: tomaId,
      title: 'Toma marcada como Tomado',
      subtitle: 'Tomado',
      startsAt: timestamp,
      status: null,
      isDueSoon: false,
      source: 'toma_event',
      payload: {
        'tomaId': tomaId,
        'action': 'tomado',
        'timestamp': timestamp.toUtc().toIso8601String()
      },
    );
    // remove pending toma entry if present and insert event
    _cachedNotifications.remove(_keyFor('toma', tomaId));
    _cachedNotifications[eventKey] = item;
    // notify other listeners via EventBus as well
    EventBus().emit({
      'type': 'toma_event',
      'action': 'tomado',
      'tomaId': tomaId,
      'timestamp': timestamp.toUtc().toIso8601String(),
    });
    notifyListeners();
  }

  Future<void> deleteFromView(String source, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(source, id);
    _dismissedKeys.add(key);
    await prefs.setStringList(
        'notificaciones_dismissed_ids', _dismissedKeys.toList());
    notifyListeners();
  }

  Future<void> markEjercicioRealizado(int ejercicioId) async {
    try {
      final key = _keyFor('exercise', ejercicioId);
      final cached = _cachedNotifications[key];

      if (cached != null && cached.payload is EjercicioUsuario) {
        final e = cached.payload as EjercicioUsuario;
        final updated = EjercicioUsuario(
          id: e.id,
          nombre: e.nombre,
          notas: e.notas,
          horario: e.horario,
          duracionMin: e.duracionMin,
          realizado: true,
        );

        await EjercicioService().updateEjercicioUsuario(ejercicioId, updated);
        _cachedNotifications[key] = NotificationItem.fromEjercicio(updated);
      }
      await refresh();

      EjercicioController ejercicioController;
      ContainerController containerController;

      try {
        ejercicioController = Get.find<EjercicioController>();
      } catch (_) {
        ejercicioController = Get.put(EjercicioController());
      }
      
      containerController = Get.find<ContainerController>();

      await ejercicioController.loadData();
      containerController
          .cargarEjercicios(ejercicioController.ejerciciosUsuario);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
