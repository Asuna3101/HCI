import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'dart:convert';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: AppColors.white,
            fontFamily: 'Titulo',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(fotoBase64: c.fotoBase64.value),
              const SizedBox(height: 16),
              Text(
                c.nombre.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _ProfileField(
                  icon: Icons.email, label: 'Correo', value: c.correo.value),
              _ProfileField(
                  icon: Icons.phone, label: 'Teléfono', value: c.celular.value),
              _ProfileField(
                icon: Icons.cake,
                label: 'Fecha de nacimiento',
                value: c.fechaNacimiento.value != null
                    ? _formatDate(c.fechaNacimiento.value!)
                    : '-',
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileField(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) {
  return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _Avatar extends StatelessWidget {
  final String fotoBase64;
  const _Avatar({required this.fotoBase64});
  @override
  Widget build(BuildContext context) {
    if (fotoBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(fotoBase64);
        return CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: MemoryImage(bytes),
          key: ValueKey(fotoBase64.length),
        );
      } catch (_) {
        // fallback below
      }
    }
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: const Icon(Icons.person, size: 64, color: AppColors.primary),
    );
  }
}
