import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final isDarkMode = false.obs;

  static const String _themeKey = 'is_dark_mode';

  @override
  void onInit() {
    super.onInit();
    cargarTema();
  }

  Future<void> cargarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_themeKey) ?? false;

    isDarkMode.value = saved;
    Get.changeThemeMode(saved ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> cambiarTema(bool value) async {
    isDarkMode.value = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);

    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}