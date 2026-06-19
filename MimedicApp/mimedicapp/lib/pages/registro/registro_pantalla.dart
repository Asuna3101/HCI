import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/components/custom_button.dart';
import 'registro_controlador.dart';

class PaginaRegistro extends StatelessWidget {
  const PaginaRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    final RegistroControlador controlador = Get.put(RegistroControlador());

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          '',
          style: TextStyle(
            fontFamily: 'Blond',
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controlador.irAlInicio(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controlador.formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo
                Image.asset(
                  'assets/img/ico.png',
                  height: 80,
                ),
                const SizedBox(height: 20),

                // Título
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontFamily: 'Blond',
                    fontSize: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de nombre
                TextFormField(
                  controller: controlador.nombreController,
                  validator: controlador.validarNombre,
                  onChanged: (_) => controlador.clearError(),
                  style: const TextStyle(fontFamily: 'Formularios'),
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de correo
                TextFormField(
                  controller: controlador.correoController,
                  validator: controlador.validarCorreo,
                  onChanged: (_) => controlador.clearError(),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'Formularios'),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de celular
                TextFormField(
                  controller: controlador.celularController,
                  validator: controlador.validarCelular,
                  onChanged: (_) => controlador.clearError(),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontFamily: 'Formularios'),
                  decoration: InputDecoration(
                    labelText: 'Número de celular',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de fecha de nacimiento
                Obx(() => InkWell(
                      onTap: () => controlador.selectFechaNacimiento(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: controlador.fechaNacimiento.value != null
                                ? AppColors.primary.withOpacity(0.5)
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: controlador.fechaNacimiento.value != null
                                  ? AppColors.primary
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                controlador.fechaNacimiento.value != null
                                    ? controlador.formatearFecha(
                                        controlador.fechaNacimiento.value!)
                                    : 'Selecciona tu fecha de nacimiento',
                                style: TextStyle(
                                  fontFamily: 'Formularios',
                                  color:
                                      controlador.fechaNacimiento.value != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Campo de contraseña
                Obx(() => TextFormField(
                      controller: controlador.contrasenaController,
                      validator: controlador.validarContrasena,
                      onChanged: (_) => controlador.clearError(),
                      obscureText: controlador.obscurePassword.value,
                      style: const TextStyle(fontFamily: 'Formularios'),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controlador.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: controlador.togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Campo de confirmar contraseña
                Obx(() => TextFormField(
                      controller: controlador.confirmarContrasenaController,
                      validator: controlador.validarConfirmarContrasena,
                      onChanged: (_) => controlador.clearError(),
                      obscureText: controlador.obscureConfirmPassword.value,
                      style: const TextStyle(fontFamily: 'Formularios'),
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controlador.obscureConfirmPassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed:
                              controlador.toggleConfirmPasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),

                // Mensaje de error
                Obx(() => controlador.errorMessage.value.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controlador.errorMessage.value,
                                style: TextStyle(color: Colors.red[600]),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),

                // Botón de registro
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: controlador.isLoading.value
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Registrando...',
                                    style: TextStyle(
                                      fontFamily: 'Botones',
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : CustomButton(
                              title: 'Registrarse',
                              onPressed: () => controlador.registrarUsuario(),
                            ),
                    )),

                const SizedBox(height: 20),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('O'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // Enlace para ir al login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(
                        fontFamily: 'Regular',
                      ),
                    ),
                    TextButton(
                      onPressed: controlador.irAlLogin,
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          fontFamily: 'Regular',
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
