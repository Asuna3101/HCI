import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/report_event.dart';
import 'package:mimedicapp/pages/home/reportes/reportes_controller.dart';
import 'package:share_plus/share_plus.dart';

class ReportDownloadSheet extends StatelessWidget {
  final ReportEventType type;
  const ReportDownloadSheet({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            title: const Text('Descargar reporte'),
            subtitle: Text(reportEventTypeToString(type)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Texto'),
            onTap: () => _handle(context, 'txt'),
          ),
          ListTile(
            leading: const Icon(Icons.web_asset),
            title: const Text('HTML'),
            onTap: () => _handle(context, 'html'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('PDF'),
            onTap: () => _handle(context, 'pdf'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_done_outlined),
            title: const Text('Guardar en dispositivo'),
            subtitle: const Text('Documentos de la app'),
            onTap: () => _handleSave(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handle(BuildContext context, String format) async {
    final c = Get.find<ReportesController>();
    final res = await c.downloadToFile(type: type, format: format);
    if (res == null) {
      if (c.error.value != null) {
        Get.snackbar('Error', c.error.value!,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
      return;
    }
    await Share.shareXFiles(
      [XFile(res.path, mimeType: res.mime, name: res.name)],
      text: 'Reporte ${reportEventTypeToString(type)}',
    );
    Get.back();
  }

  Future<void> _handleSave(BuildContext context) async {
    final c = Get.find<ReportesController>();
    final res = await c.downloadAndSave(type: type, format: 'pdf');
    if (res == null) {
      if (c.error.value != null) {
        Get.snackbar('Error', c.error.value!,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2));
      }
      return;
    }
    Get.back();
    Get.snackbar('Guardado', 'Archivo guardado en:\n${res.path}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3));
  }
}
