import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/home_page.dart';

class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: Get.nestedKey(1),
      initialRoute: '/',
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => const HomePage(),
        settings: settings,
      ),
    );
  }
}
