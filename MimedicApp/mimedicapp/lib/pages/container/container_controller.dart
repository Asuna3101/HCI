import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/navigation/tabs.dart';
import 'package:mimedicapp/pages/home/home_page.dart';
import 'package:mimedicapp/pages/progreso/progreso_page.dart';
import 'package:mimedicapp/pages/logros/logros_page.dart';
import 'package:mimedicapp/pages/configuracion/settings_page.dart';

class ContainerController extends GetxController {
  final currentTab = AppTab.home.obs;
  final List<AppTab> tabHistory = [];

  final List<Widget> views = const [
    HomePage(),
    ProgresoPage(),
    LogrosPage(),
    SettingsPage(),
  ];

  void changeTab(AppTab tab) {
    if (tab != currentTab.value) {
      tabHistory.add(currentTab.value);
      currentTab.value = tab;
    }
  }

  bool handleBack() {
    if (tabHistory.isNotEmpty) {
      currentTab.value = tabHistory.removeLast();
      return false;
    }
    return true;
  }
}
