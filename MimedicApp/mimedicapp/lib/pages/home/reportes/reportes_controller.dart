import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:mimedicapp/models/report_event.dart';
import 'package:mimedicapp/models/report_summary.dart';
import 'package:mimedicapp/services/reportes_service.dart';
import 'package:mimedicapp/services/user_service.dart';
import 'package:mimedicapp/utils/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ReportesController extends GetxController {
  final _userService = UserService();
  final _reportes = ReportesService();

  final isLoading = false.obs;
  final error = RxnString();
  final nombre = ''.obs;
  final fechaNacimiento = Rxn<DateTime>();
  final fotoBase64 = ''.obs;
  final eventos = <ReportEventModel>[].obs;
  final modulos = <ReportEventType, List<ReportEventModel>>{}.obs;
  final descargando = false.obs;

  StreamSubscription<dynamic>? _eventSub;
  static const _tomasHistoryKey = 'completed_tomas_history';

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
      final summary = await _reportes.getSummary();
      final user = summary.user;
      nombre.value = user.nombre;
      fechaNacimiento.value = user.fechaNacimiento;
      fotoBase64.value = user.foto ?? '';

      final List<ReportEventModel> data = [...summary.timeline];

      // merge local tomas (offline)
      final tomasLocal = await _readMedicationEvents();
      data.addAll(tomasLocal.map(
        (e) => ReportEventModel(
          type: ReportEventType.toma,
          title: e['title'] ?? 'Toma completada',
          subtitle: e['detail'] ?? e['subtitle'] ?? '',
          status: e['status'] ?? 'Completado',
          date: DateTime.tryParse(
                  e['completedAt'] ?? e['timestamp'] ?? '') ??
              DateTime.now(),
        ),
      ));

      data.sort((a, b) => b.date.compareTo(a.date));
      eventos.assignAll(data);
      modulos.assignAll(_groupByType(data));
    } catch (e) {
      error.value = 'No se pudo cargar los reportes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<DownloadFileResult?> downloadToFile(
      {required ReportEventType type, String format = 'txt'}) async {
    try {
      descargando.value = true;
      final mod = reportEventTypeToString(type);
      final res =
          await _reportes.downloadModule(module: mod, format: format);
      final path = await _saveToTemp(res.bytes, res.filename);
      return DownloadFileResult(path: path, mime: res.mime, name: res.filename);
    } catch (e) {
      error.value = 'No se pudo descargar: $e';
      return null;
    } finally {
      descargando.value = false;
    }
  }

  /// Descarga y guarda en la carpeta de documentos de la app (persistente).
  Future<DownloadFileResult?> downloadAndSave(
      {required ReportEventType type, String format = 'pdf'}) async {
    try {
      descargando.value = true;
      final mod = reportEventTypeToString(type);
      final res = await _reportes.downloadModule(module: mod, format: format);
      final dirPath = await _preferredDownloadDir();
      final path = await _saveToDir(dirPath, res.bytes, res.filename);
      return DownloadFileResult(path: path, mime: res.mime, name: res.filename);
    } catch (e) {
      error.value = 'No se pudo guardar: $e';
      return null;
    } finally {
      descargando.value = false;
    }
  }

  Future<String> _saveToTemp(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    return _saveToDir(dir.path, bytes, filename);
  }

  Future<String> _saveToDir(String dirPath, List<int> bytes, String filename) async {
    final file = File('$dirPath/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// Intenta guardar en una carpeta visible (Downloads en Android/desktop, Documents en iOS).
  Future<String> _preferredDownloadDir() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Forzar carpeta pública de descargas en Android
      final downloads = Directory('/storage/emulated/0/Download');
      if (downloads.existsSync()) return downloads.path;
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext.path;
    } else {
      // iOS/desktop: usar Downloads si está disponible
      try {
        final dl = await getDownloadsDirectory();
        if (dl != null) return dl.path;
      } catch (_) {}
    }
    // Fallback: documentos de la app
    final docs = await getApplicationDocumentsDirectory();
    return docs.path;
  }

  Future<List<Map<String, dynamic>>> _readMedicationEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_tomasHistoryKey) ?? <String>[];
    return raw.map((e) {
      final map = Map<String, dynamic>.from(jsonDecode(e));
      if (map['completedAt'] == null && map['timestamp'] != null) {
        map['completedAt'] = map['timestamp'];
      }
      return map;
    }).toList();
  }

  void _listenMedicationEvents() {
    _eventSub = EventBus().stream.listen((e) async {
      if (e['type'] == 'toma_event' && e['action'] == 'tomado') {
        final timestamp = e['timestamp'] as String? ??
            DateTime.now().toUtc().toIso8601String();
        await _persistMedicationEvent({
          'id': 'med_${e['tomaId'] ?? timestamp}',
          'category': 'TaskCategory.medicamentos',
          'title': 'Toma completada',
          'detail':
              '${e['medicamentoNombre'] ?? ''} ${e['dosis'] ?? ''} ${e['unidad'] ?? ''}'.trim(),
          'completedAt': timestamp,
          'status': 'Completado',
        });
      }
    });
  }

  Future<void> _persistMedicationEvent(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_tomasHistoryKey) ?? <String>[];
    raw.add(jsonEncode(event));
    await prefs.setStringList(_tomasHistoryKey, raw);
    await cargar();
  }

  Map<ReportEventType, List<ReportEventModel>> _groupByType(
      List<ReportEventModel> list) {
    final Map<ReportEventType, List<ReportEventModel>> res = {};
    for (final e in list) {
      res.putIfAbsent(e.type, () => []);
      res[e.type]!.add(e);
    }
    for (final v in res.values) {
      v.sort((a, b) => b.date.compareTo(a.date));
    }
    return res;
  }
}

class DownloadFileResult {
  final String path;
  final String mime;
  final String name;
  DownloadFileResult({required this.path, required this.mime, required this.name});
}
