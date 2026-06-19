import 'package:get/get.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final isProcessing = false.obs;

  /// Realiza el cierre de sesión: borra token y prefs relevantes, luego
  /// navega a la pantalla de inicio limpiando la pila.
  Future<void> performLogout() async {
    isProcessing.value = true;
    try {
      await ApiService().logout();
      final prefs = await SharedPreferences.getInstance();
      // Limpiar claves relacionadas con sesión/local cache si existen
      await prefs.remove('notificaciones_seen_pending_ids');
      await prefs.remove('notificaciones_dismissed_ids');
    } catch (_) {
      // ignore errors
    }
    isProcessing.value = false;
    // Navegar al inicio y limpiar stack
    Get.offAllNamed('/inicio');
  }
}
