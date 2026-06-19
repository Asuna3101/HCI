import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/services/ejercicio_service.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'package:mimedicapp/services/toma_service.dart';
import 'package:mimedicapp/utils/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskCategory { ejercicio, medicamentos, citas }

class TaskItem {
  final String id;
  final TaskCategory category;
  final String title;
  final String detail;
  final DateTime when;
  final String? status;

  TaskItem({
    required this.id,
    required this.category,
    required this.title,
    required this.detail,
    required this.when,
    this.status,
  });
}

class CompletedTask extends TaskItem {
  CompletedTask({
    required super.id,
    required super.category,
    required super.title,
    required super.detail,
    required DateTime completedAt,
    super.status,
  }) : super(when: completedAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.toString(),
        'title': title,
        'detail': detail,
        'completedAt': when.toIso8601String(),
        'status': status,
      };

  factory CompletedTask.fromJson(Map<String, dynamic> json) => CompletedTask(
        id: json['id'] ?? '',
        category: TaskCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => TaskCategory.medicamentos,
        ),
        title: json['title'] ?? '',
        detail: json['detail'] ?? '',
        completedAt:
            DateTime.tryParse(json['completedAt'] ?? '') ?? DateTime.now(),
        status: json['status'],
      );
}

class PendingTask extends TaskItem {
  PendingTask({
    required super.id,
    required super.category,
    required super.title,
    required super.detail,
    required DateTime when,
    super.status,
  }) : super(when: when);
}

class TasksController extends GetxController {
  final _health = HealthService();
  final _ejercicios = EjercicioService();
  final _tomas = TomaService();

  final isLoading = false.obs;
  final error = RxnString();
  final completadas = <TaskCategory, List<CompletedTask>>{}.obs;
  final pendientes = <TaskCategory, List<PendingTask>>{}.obs;

  StreamSubscription<dynamic>? _eventSub;
  static const _medicationKey = 'completed_tomas_history';

  @override
  void onInit() {
    super.onInit();
    _listenMedicationEvents();
    cargar();
  }

  @override
  void onClose() {
    _eventSub?.cancel();
    super.onClose();
  }

  Future<void> cargar() async {
    isLoading.value = true;
    error.value = null;
    try {
      final ejerciciosDone = await _loadEjerciciosCompletados();
      final ejerciciosPending = await _loadEjerciciosPendientes();

      final citasDone = await _loadCitasCompletadas();
      final citasPending = await _loadCitasPendientes();

      final medsDone = await _loadMedicationEvents();
      final medsPending = await _loadPendingTomas();

      completadas.assignAll({
        TaskCategory.ejercicio: ejerciciosDone,
        TaskCategory.citas: citasDone,
        TaskCategory.medicamentos: medsDone,
      });

      pendientes.assignAll({
        TaskCategory.ejercicio: ejerciciosPending,
        TaskCategory.citas: citasPending,
        TaskCategory.medicamentos: medsPending,
      });
    } catch (e) {
      error.value = 'No se pudieron cargar las tareas: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => cargar();

  Future<List<CompletedTask>> _loadEjerciciosCompletados() async {
    final data = await _ejercicios.getEjerciciosUsuario();
    final list = data
        .where((e) => e.realizado == true)
        .map(
          (e) => CompletedTask(
            id: 'ej_${e.id}',
            category: TaskCategory.ejercicio,
            title: e.nombre ?? 'Ejercicio',
            detail: e.notas ?? '',
            completedAt: _parseHorarioToday(e.horario),
            status: 'Realizado',
          ),
        )
        .toList();
    list.sort((a, b) => b.when.compareTo(a.when));
    return list;
  }

  Future<List<PendingTask>> _loadEjerciciosPendientes() async {
    final data = await _ejercicios.getEjerciciosUsuario();
    final list = data
        .where((e) => e.realizado != true)
        .map(
          (e) => PendingTask(
            id: 'ej_${e.id}',
            category: TaskCategory.ejercicio,
            title: e.nombre ?? 'Ejercicio',
            detail: e.notas ?? '',
            when: _parseHorarioToday(e.horario),
            status: 'Pendiente',
          ),
        )
        .toList();
    list.sort((a, b) => a.when.compareTo(b.when));
    return list;
  }

  Future<List<CompletedTask>> _loadCitasCompletadas() async {
    final history = await _health.getHistoryReminders();
    final list = history
        .where((c) => c.status != AppointmentStatus.pendiente)
        .map(
          (c) => CompletedTask(
            id: 'cita_${c.id}',
            category: TaskCategory.citas,
            title: 'Cita con ${c.doctor.nombre}',
            detail: '${c.clinic.nombre} • ${c.specialty.nombre}',
            completedAt: c.startsAt,
            status: c.status.label,
          ),
        )
        .toList();
    list.sort((a, b) => b.when.compareTo(a.when));
    return list;
  }

  Future<List<PendingTask>> _loadCitasPendientes() async {
    final upcoming = await _health.getUpcomingReminders();
    final list = upcoming
        .map(
          (c) => PendingTask(
            id: 'cita_${c.id}',
            category: TaskCategory.citas,
            title: 'Cita con ${c.doctor.nombre}',
            detail: '${c.clinic.nombre} • ${c.specialty.nombre}',
            when: c.startsAt,
            status: c.status.label,
          ),
        )
        .toList();
    list.sort((a, b) => a.when.compareTo(b.when));
    return list;
  }

  Future<List<PendingTask>> _loadPendingTomas() async {
    final now = DateTime.now().toUtc();
    final tomas = await _tomas.getPendingTomas(at: now);
    return tomas
        .map(
          (t) => PendingTask(
            id: 'toma_${t.id}',
            category: TaskCategory.medicamentos,
            title: 'Toma pendiente',
            detail: '${t.medicamentoNombre} ${t.dosis} ${t.unidad}',
            when: t.adquired.toLocal(),
            status: 'Pendiente',
          ),
        )
        .toList()
      ..sort((a, b) => a.when.compareTo(b.when));
  }

  Future<List<CompletedTask>> _loadMedicationEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_medicationKey) ?? <String>[];
    final events = raw
        .map((e) => CompletedTask.fromJson(jsonDecode(e)))
        .where((e) => e.category == TaskCategory.medicamentos)
        .toList();
    events.sort((a, b) => b.when.compareTo(a.when));
    return events;
  }

  Future<void> _persistMedicationEvents(List<CompletedTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_medicationKey, raw);
  }

  void _listenMedicationEvents() {
    _eventSub = EventBus().stream.listen((e) async {
      if (e['type'] == 'toma_event' && e['action'] == 'tomado') {
        final timestamp = e['timestamp'] as String? ??
            DateTime.now().toUtc().toIso8601String();
        final task = CompletedTask(
          id: 'med_${e['tomaId'] ?? timestamp}',
          category: TaskCategory.medicamentos,
          title: 'Toma completada',
          detail:
              '${e['medicamentoNombre'] ?? ''} ${e['dosis'] ?? ''} ${e['unidad'] ?? ''}'.trim(),
          completedAt: DateTime.tryParse(timestamp) ?? DateTime.now(),
          status: 'Completado',
        );

        final current = List<CompletedTask>.from(
            completadas[TaskCategory.medicamentos] ?? []);
        current.removeWhere((t) => t.id == task.id);
        current.add(task);
        current.sort((a, b) => b.when.compareTo(a.when));
        completadas[TaskCategory.medicamentos] = current;

        await _persistMedicationEvents(current);
      }
    });
  }

  DateTime _parseHorarioToday(String? horario) {
    if (horario == null) return DateTime.now();
    final parts = horario.split(':');
    if (parts.length < 2) return DateTime.now();
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  }
}
