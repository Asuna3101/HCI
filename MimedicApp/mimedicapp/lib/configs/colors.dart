import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Identidad
  static const Color primary = Color(0xFF3A1855); // Morado (texto/brand)
  static const Color white = Color(0xFFFFFFFF); // Fondos/superficies
  static const Color accent = Color(0xFFE91E63); // Rosado (botones/íconos)

  // Apoyos
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);

  //Métodos dinámicos para obtener colores según componente
  static Color getButtonColor(BuildContext context) {
    return primary; // Morado como color del botón por defecto
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primary // Usar morado oscuro en modo oscuro
        : white; // Usar blanco en modo claro
  }
}
