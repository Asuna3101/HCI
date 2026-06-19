import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onChangePhoto;
  final VoidCallback onChangePassword;
  final VoidCallback onDeleteAccount;
  const ProfileActions({
    super.key,
    required this.onChangePhoto,
    required this.onChangePassword,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seguridad y cuenta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _ActionTile(
          icon: Icons.image_outlined,
          color: AppColors.primary,
          title: 'Cambiar foto de perfil',
          onTap: onChangePhoto,
        ),
        _ActionTile(
          icon: Icons.lock_reset_rounded,
          color: const Color(0xFF5C6BC0),
          title: 'Cambiar contraseña',
          onTap: onChangePassword,
        ),
        _ActionTile(
          icon: Icons.delete_forever_rounded,
          color: Colors.redAccent,
          title: 'Eliminar mi cuenta',
          onTap: onDeleteAccount,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
