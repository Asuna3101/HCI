import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  // ==========================
  // Marca
  // ==========================

  static const Color primary = Color(0xFF3A1855);
  static const Color accent = Color(0xFFE91E63);

  // ==========================
  // Estados
  // ==========================

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);

  // ==========================
  // Gamificación
  // ==========================

  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF8DC);

  // ==========================
  // Compatibilidad
  // (mantener porque muchos archivos lo usan)
  // ==========================

  static const Color white = Colors.white;

  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);

  static const Color dark = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2A2A2A);

  // ==========================
  // Colores dinámicos
  // ==========================

  static bool get isDark => Get.isDarkMode;

  static Color get background =>
      isDark ? dark : white;

  static Color get surface =>
      isDark ? darkCard : white;

  static Color get card =>
      isDark ? const Color(0xFF232323) : white;

  static Color get border =>
      isDark ? Colors.white12 : grey200;

  static Color get text =>
      isDark ? Colors.white : primary;

  static Color get subtitle =>
      isDark ? Colors.white70 : grey600;

  static Color get icon =>
      isDark ? Colors.white : primary;

  static Color get input =>
      isDark ? darkSurface : white;

  static Color get chartBackground =>
      isDark ? darkCard : white;

  static Color get divider =>
      isDark ? Colors.white12 : grey200;

  static Color get progressBackground =>
      isDark ? Colors.white24 : grey200;
}