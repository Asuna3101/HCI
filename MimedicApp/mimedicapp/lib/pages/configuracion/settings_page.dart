import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/components/custom_button.dart';
import 'package:mimedicapp/pages/configuracion/settings_controller.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/profile/profile_controller.dart';
import 'package:mimedicapp/pages/profile/profile_actions.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmLogout(BuildContext context, SettingsController controller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Cerrar sesión')),
        ],
      ),
    );

    if (confirm == true) {
      await controller.performLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final profile = Get.put(ProfileController());
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Configuración',
            style: TextStyle(
              fontFamily: 'Blond',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 16),
          ProfileActions(
            onChangePhoto: () => _showPhotoDialog(context, profile),
            onChangePassword: () => _showChangePassDialog(context, profile),
            onDeleteAccount: () => _confirmDelete(context, profile),
          ),

          const SizedBox(height: 16),

          // Logout button (visual only, controller handles logic)
          Obx(() {
            if (controller.isProcessing.value) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                      SizedBox(width: 12),
                      Text('Cerrando sesión...'),
                    ],
                  ),
                ),
              );
            }

            return CustomButton(
              title: 'Cerrar sesión',
              onPressed: () => _confirmLogout(context, controller),
            );
          }),
        ],
      ),
    );
  }
}

void _showPhotoDialog(BuildContext context, ProfileController c) {
  Get.dialog(AlertDialog(
    title: const Text('Cambiar foto'),
    content: const Text('Selecciona una foto desde tu galería.'),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
      ElevatedButton(
        onPressed: () async {
          try {
            await c.pickAndUploadPhoto();
            Get.back();
            Get.dialog(AlertDialog(
              title: const Text('Foto actualizada'),
              content: const Text('Tu foto de perfil se actualizó con éxito.'),
              actions: [
                TextButton(
                    onPressed: () => Get.back(), child: const Text('Aceptar')),
              ],
            ));
          } catch (e) {
            Get.back();
            Get.dialog(AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                    onPressed: () => Get.back(), child: const Text('Aceptar')),
              ],
            ));
          }
        },
        child: const Text('Abrir galería'),
      ),
    ],
  ));
}

void _showChangePassDialog(BuildContext context, ProfileController c) {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Cambiar contraseña'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: oldCtrl,
            decoration: const InputDecoration(labelText: 'Contraseña actual'),
            obscureText: true,
          ),
          TextField(
            controller: newCtrl,
            decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            obscureText: true,
          ),
          TextField(
            controller: confirmCtrl,
            decoration: const InputDecoration(labelText: 'Confirmar nueva'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (newCtrl.text == confirmCtrl.text &&
                newCtrl.text.isNotEmpty &&
                oldCtrl.text.isNotEmpty) {
              if (newCtrl.text.length < 6) {
                Get.dialog(AlertDialog(
                  title: const Text('Error'),
                  content: const Text(
                      'La nueva contraseña debe tener al menos 6 caracteres.'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Aceptar')),
                  ],
                ));
                return;
              }
              try {
                await c.changePassword(
                    oldPass: oldCtrl.text, newPass: newCtrl.text);
                Get.back();
                Get.dialog(AlertDialog(
                  title: const Text('Contraseña actualizada'),
                  content: const Text(
                      'Tu contraseña ha sido actualizada correctamente.'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Aceptar')),
                  ],
                ));
              } catch (e) {
                Get.dialog(AlertDialog(
                  title: const Text('Error'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Aceptar')),
                  ],
                ));
              }
            } else {
              Get.dialog(AlertDialog(
                title: const Text('Error'),
                content: const Text('Las contraseñas no coinciden'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Aceptar')),
                ],
              ));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

void _confirmDelete(BuildContext context, ProfileController c) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Eliminar cuenta'),
      content: const Text(
          'Esta acción desactivará tu cuenta. ¿Deseas continuar?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () async {
            try {
              await c.deleteAccount();
              Get.back();
              Get.snackbar('Cuenta', 'Cuenta desactivada',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2));
              Get.offAllNamed('/sign-in');
            } catch (e) {
              Get.snackbar('Error', e.toString(),
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3));
            }
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
