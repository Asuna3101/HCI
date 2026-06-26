import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
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
        title: Text(
          'Perfil',
          style: TextStyle(
            color: AppColors.white,
            fontFamily: 'Titulo',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accent, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final progreso = c.progreso.value;

        return RefreshIndicator(
          onRefresh: c.loadProfile,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfileHeader(
                  fotoBase64: c.fotoBase64.value,
                  nombre: c.nombre.value,
                  correo: c.correo.value,
                ),
                const SizedBox(height: 18),

                _LevelCard(
                  nivel: progreso.nivel,
                  nombreNivel: progreso.nombreNivel,
                  puntos: progreso.puntosTotal,
                  progresoNivel: progreso.progresoNivel,
                  puntosSiguiente: progreso.puntosParaSiguienteNivel,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Racha actual',
                        value: '${progreso.rachaActual}',
                        subtitle: 'días',
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events_rounded,
                        label: 'Mejor racha',
                        value: '${progreso.rachaMayor}',
                        subtitle: 'días',
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Completados',
                        value: '${c.totalHabitosCompletados.value}',
                        subtitle: 'últimos 7 días',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.workspace_premium_rounded,
                        label: 'Logros',
                        value: '${c.logrosDesbloqueados}',
                        subtitle: 'de ${c.logros.length}',
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _InfoSection(
                  children: [
                    _ProfileField(
                      icon: Icons.email_rounded,
                      label: 'Correo',
                      value: c.correo.value,
                    ),
                    _ProfileField(
                      icon: Icons.phone_rounded,
                      label: 'Teléfono',
                      value: c.celular.value.isNotEmpty ? c.celular.value : '-',
                    ),
                    _ProfileField(
                      icon: Icons.cake_rounded,
                      label: 'Fecha de nacimiento',
                      value: c.fechaNacimiento.value != null
                          ? _formatDate(c.fechaNacimiento.value!)
                          : '-',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Editar perfil',
                        'Esta opción se implementará en la siguiente versión.',
                      );
                    },
                    icon: Icon(Icons.edit_rounded),
                    label: Text('Editar perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String fotoBase64;
  final String nombre;
  final String correo;

  const _ProfileHeader({
    required this.fotoBase64,
    required this.nombre,
    required this.correo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Avatar(fotoBase64: fotoBase64),
        const SizedBox(height: 12),
        Text(
          nombre.isNotEmpty ? nombre : 'Usuario',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          correo,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.subtitle,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int nivel;
  final String nombreNivel;
  final int puntos;
  final double progresoNivel;
  final int puntosSiguiente;

  const _LevelCard({
    required this.nivel,
    required this.nombreNivel,
    required this.puntos,
    required this.progresoNivel,
    required this.puntosSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nivel $nivel · $nombreNivel',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$puntos pts',
            style: TextStyle(
              color: AppColors.card,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresoNivel.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$puntosSiguiente pts para el siguiente nivel',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;

  const _InfoSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppColors.isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.icon),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
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
          radius: 52,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: MemoryImage(bytes),
          key: ValueKey(fotoBase64.length),
        );
      } catch (_) {}
    }

    return CircleAvatar(
      radius: 52,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: Icon(
        Icons.person_rounded,
        size: 64,
        color: AppColors.primary,
      ),
    );
  }
}