import 'package:flutter/material.dart';

enum AppTab { home, progreso, logros, ajustes }

const List<AppTab> allTabs = [
  AppTab.home,
  AppTab.progreso,
  AppTab.logros,
  AppTab.ajustes,
];

const Map<AppTab, IconData> bottomTabIcons = {
  AppTab.home: Icons.home_rounded,
  AppTab.progreso: Icons.bar_chart_rounded,
  AppTab.logros: Icons.emoji_events_rounded,
  AppTab.ajustes: Icons.settings_rounded,
};

const Map<AppTab, String> bottomTabLabels = {
  AppTab.home: 'Hoy',
  AppTab.progreso: 'Progreso',
  AppTab.logros: 'Logros',
  AppTab.ajustes: 'Ajustes',
};
