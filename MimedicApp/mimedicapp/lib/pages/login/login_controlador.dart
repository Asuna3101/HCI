import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';

class LoginControlador extends GetxController {
  final UserService _userService = UserService();

  // Controllers para los campos del formulario
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  // Variables reactivas para el estado de la UI
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool rememberMe = false.obs;

  // Clave para el formulario
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Alternar visibilidad de la contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Alternar recordar usuario
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  /// Limpiar mensaje de error
  void clearError() {
    errorMessage.value = '';
  }

  /// Iniciar sesión
  Future<void> iniciarSesion() async {
    try {
      clearError();

      if (!formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      // Intentar hacer login
      final result = await _userService.login(
        correoController.text.trim(),
        contrasenaController.text,
      );

      print('Login exitoso: $result'); // Para debugging

      // Limpiar historial local de tomas al iniciar sesión (puede pertenecer a otro usuario)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('completed_tomas_history');

      // Si llegamos aquí, el login fue exitoso
      Get.snackbar(
        '¡Bienvenido!',
        'Has iniciado sesión correctamente',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );

      // Limpiar el formulario
      _clearForm();

      // Esperar un poco para que se vea el mensaje
      await Future.delayed(const Duration(seconds: 1));

      // Navegar de vuelta al inicio
      Get.offAllNamed('/app');
    } catch (e) {
      // Capturar cualquier error
      print('Error en login: $e'); // Para debugging

      String errorMsg = 'Error al iniciar sesión. Verifica tus credenciales.';
      if (e.toString().contains('credenciales')) {
        errorMsg = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
      }

      errorMessage.value = errorMsg;
      Get.snackbar(
        'Error de inicio de sesión',
        errorMsg,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpiar el formulario
  void _clearForm() {
    correoController.clear();
    contrasenaController.clear();
    formKey.currentState?.reset();
  }

  /// Ir al registro
  void irAlRegistro() {
    Get.toNamed('/sign-up');
  }

  /// Ir al inicio
  void irAlInicio() {
    Get.offAllNamed('/inicio');
  }

  /// Recuperar contraseña (placeholder)
  void recuperarContrasena() {
    Get.toNamed('/recover', arguments: correoController.text);
  }

  // Validadores para los campos
  String? validarCorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? validarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

}
