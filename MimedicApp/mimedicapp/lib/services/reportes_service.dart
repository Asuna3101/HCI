import 'package:mimedicapp/configs/api_config.dart';
import 'package:mimedicapp/models/report_event.dart';
import 'package:mimedicapp/models/report_summary.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'package:http/http.dart' as http;

class ReportesService {
  final ApiService _api = ApiService();

  Future<ReportSummary> getSummary() async {
    final data =
        await _api.get('${ApiConfig.baseUrl}/reportes/summary', auth: true);
    return ReportSummary.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<ReportEventModel>> getModuleEvents(String module) async {
    final data = await _api.get(
        '${ApiConfig.baseUrl}/reportes/modulo?module=$module',
        auth: true);
    return (data as List)
        .map((e) => ReportEventModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<_DownloadResult> downloadModule(
      {required String module, String format = 'txt'}) async {
    final resp = await _api.getBytes(
        '${ApiConfig.baseUrl}/reportes/modulo/download?module=$module&format=$format',
        auth: true);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return _DownloadResult(
        bytes: resp.bodyBytes,
        mime: resp.headers['content-type'] ?? 'application/octet-stream',
        filename: _parseFilename(resp.headers['content-disposition']) ??
            'reporte_$module.$format',
      );
    }
    throw ApiException('Descarga falló: HTTP ${resp.statusCode}');
  }

  String? _parseFilename(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final parts = contentDisposition.split(';');
    for (final p in parts) {
      final trimmed = p.trim();
      if (trimmed.toLowerCase().startsWith('filename=')) {
        return trimmed.substring(9).replaceAll('"', '');
      }
    }
    return null;
  }
}

class _DownloadResult {
  final List<int> bytes;
  final String mime;
  final String filename;
  _DownloadResult({required this.bytes, required this.mime, required this.filename});
}
