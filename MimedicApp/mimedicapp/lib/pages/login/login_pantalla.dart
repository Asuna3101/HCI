import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controlador.dart';
import '../../components/custom_button.dart';
import 'package:mimedicapp/configs/colors.dart';

class PaginaLogin extends StatelessWidget {
  const PaginaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginControlador controlador = Get.put(LoginControlador());

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
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontFamily: 'Blond',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Ingresa tus credenciales para acceder',
                  style: TextStyle(
                    fontFamily: 'formulario',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // Campo de correo
                TextFormField(
                  controller: controlador.correoController,
                  keyboardType: TextInputType.emailAddress,
                  validator: controlador.validarCorreo,
                  onChanged: (_) => controlador.clearError(),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'Ingresa tu correo',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campo de contraseña
                Obx(() => TextFormField(
                      controller: controlador.contrasenaController,
                      obscureText: controlador.obscurePassword.value,
                      validator: controlador.validarContrasena,
                      onChanged: (_) => controlador.clearError(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingresa tu contraseña',
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
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    )),

                const SizedBox(height: 16),

                // Recordar y recuperar contraseña
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() => Checkbox(
                              value: controlador.rememberMe.value,
                              onChanged: (_) => controlador.toggleRememberMe(),
                            )),
                        const Text('Recordarme'),
                      ],
                    ),
                    TextButton(
                      onPressed: controlador.recuperarContrasena,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ],
                ),

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

                // Botón de iniciar sesión
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: controlador.isLoading.value
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
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
                                  Text('Iniciando sesión...'),
                                ],
                              ),
                            )
                          : CustomButton(
                              title: 'Iniciar Sesión',
                              onPressed: () => controlador.iniciarSesion(),
                            ),
                    )),

                const SizedBox(height: 30),

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

                const SizedBox(height: 30),

                // Ir al registro
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta? '),
                      TextButton(
                        onPressed: controlador.irAlRegistro,
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
