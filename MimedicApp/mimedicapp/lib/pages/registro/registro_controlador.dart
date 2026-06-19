import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/user_service.dart';
import '../../services/api_service.dart';

class RegistroControlador extends GetxController {
  final UserService _userService = UserService();

  // Controllers para los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController =
      TextEditingController();

  // Variable reactiva para la fecha de nacimiento
  final Rx<DateTime?> fechaNacimiento = Rx<DateTime?>(null);

  // Variables reactivas para el estado de la UI
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString errorMessage = ''.obs;

  // Claves para el formulario
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  /// Alternar visibilidad de la contraseña
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Alternar visibilidad de confirmar contraseña
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// Seleccionar fecha de nacimiento
  Future<void> selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaNacimiento.value ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // Removemos el locale para evitar errores de configuración
      helpText: 'Seleccionar fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      fechaNacimiento.value = picked;
    }
  }

  /// Validar el formulario
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!validarFechaNacimiento()) {
      return false;
    }

    if (contrasenaController.text != confirmarContrasenaController.text) {
      errorMessage.value = 'Las contraseñas no coinciden';
      return false;
    }

    if (contrasenaController.text.length < 6) {
      errorMessage.value = 'La contraseña debe tener al menos 6 caracteres';
      return false;
    }

    if (contrasenaController.text.length > 72) {
      errorMessage.value = 'La contraseña no puede tener más de 72 caracteres';
      return false;
    }

    return true;
  }

  /// Limpiar mensaje de error
  void clearError() {
    errorMessage.value = '';
  }

  /// Formatear fecha para mostrar
  String formatearFecha(DateTime fecha) {
    final List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  /// Validar fecha de nacimiento
  bool validarFechaNacimiento() {
    if (fechaNacimiento.value == null) {
      errorMessage.value = 'Por favor selecciona tu fecha de nacimiento';
      return false;
    }

    final now = DateTime.now();
    final age = now.year - fechaNacimiento.value!.year;
    final monthDiff = now.month - fechaNacimiento.value!.month;
    final dayDiff = now.day - fechaNacimiento.value!.day;

    // Calcular edad exacta
    final exactAge =
        age - ((monthDiff < 0 || (monthDiff == 0 && dayDiff < 0)) ? 1 : 0);

    if (exactAge < 13) {
      errorMessage.value = 'Debes tener al menos 13 años para registrarte';
      return false;
    }

    if (exactAge > 120) {
      errorMessage.value = 'Por favor ingresa una fecha de nacimiento válida';
      return false;
    }

    return true;
  }

  /// Registrar usuario
  Future<void> registrarUsuario() async {
    try {
      // Evitar llamadas concurrentes / doble envío
      if (isLoading.value) return;
      clearError();

      if (!_validateForm()) {
        return;
      }

      // Marcar carga antes de enviar para bloquear reintentos rápidos
      isLoading.value = true;

      // Crear el usuario con los datos del formulario
      final usuario = Usuario.forRegistration(
        nombre: nombreController.text.trim(),
        fechaNacimiento: fechaNacimiento.value!,
        celular: celularController.text.trim(),
        correo: correoController.text.trim(),
        contrasena: contrasenaController.text,
      );

      // Registrar usuario en el backend
      await _userService.createUser(usuario);

      // Mostrar mensaje de éxito
      Get.snackbar(
        '¡Registro exitoso!',
        'Tu cuenta ha sido creada correctamente',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 3),
      );

      // Limpiar el formulario
      _clearForm();

      // Navegar a la pantalla de login después del registro
      Get.offAllNamed('/sign-in');
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error de registro',
        e.message,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      errorMessage.value = 'Error inesperado. Inténtalo de nuevo.';
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 4),
      );
      print('Error en registro: $e'); // Para debugging
    } finally {
      isLoading.value = false;
    }
  }

  void _disposeControllers() {
    nombreController.dispose();
    correoController.dispose();
    celularController.dispose();
    contrasenaController.dispose();
    confirmarContrasenaController.dispose();
  }

  /// Limpiar el formulario
  void _clearForm() {
    nombreController.clear();
    correoController.clear();
    celularController.clear();
    contrasenaController.clear();
    confirmarContrasenaController.clear();
    fechaNacimiento.value = null;
    formKey.currentState?.reset();
  }

  /// Ir al login
  void irAlLogin() {
    Get.toNamed('/sign-in'); // Asegúrate de tener esta ruta definida
  }

  /// Ir al inicio
  void irAlInicio() {
    Get.offAllNamed('/inicio');
  }

  // Validadores para los campos
  String? validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

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

  String? validarCelular(String? value) {
    if (value == null || value.isEmpty) {
      return 'El celular es requerido';
    }
    // Normalizar: eliminar espacios y caracteres no numéricos
    final normalized = value.replaceAll(RegExp(r'\D'), '');

    // Validar exactamente 9 dígitos
    if (!RegExp(r'^\d{9}$').hasMatch(normalized)) {
      return 'El celular debe tener exactamente 9 dígitos';
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
    if (value.length > 72) {
      return 'La contraseña no puede tener más de 72 caracteres';
    }
    return null;
  }

  String? validarConfirmarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != contrasenaController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
