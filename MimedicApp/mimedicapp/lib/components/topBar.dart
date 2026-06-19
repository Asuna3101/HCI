import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/notificaciones/notificaciones_page.dart';
import 'package:mimedicapp/pages/profile/profile_page.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget { 

  const Topbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(
          'assets/img/ico.png',
          height: 10,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.accent, size: 30),
          onPressed: () => Get.to(() => const NotificationsPage()),
        ),
        IconButton(
          icon: const Icon(Icons.person_2_rounded, color: AppColors.accent, size: 30),
          onPressed: () => Get.to(() => const ProfilePage()),
        ),
      ],
    );
  }
}


