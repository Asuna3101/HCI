import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/navigation/tabs.dart';

class Bottombar extends StatelessWidget {
  final AppTab current;
  final ValueChanged<AppTab> onTap;

  const Bottombar({
    super.key,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = allTabs;
    final selectedIndex = tabs.indexOf(current);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 6),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => onTap(tabs[index]),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 40,
          items: tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(bottomTabIcons[tab]),
              label: '',
            );
          }).toList(),
        ),
      ),
    );
  }
}
