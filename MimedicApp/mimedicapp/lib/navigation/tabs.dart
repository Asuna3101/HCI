import 'package:flutter/material.dart';

enum AppTab { home, tasks, settings }

const List<AppTab> allTabs = [
  AppTab.home,
  AppTab.tasks,
  AppTab.settings
];


const Map<AppTab, IconData> bottomTabIcons = {
  AppTab.home: Icons.home_rounded,
  AppTab.tasks: Icons.edit_note_rounded,
  AppTab.settings: Icons.menu_rounded,
};