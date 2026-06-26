import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/components/bottomBar.dart';
import 'package:mimedicapp/components/topBar.dart';
import 'package:mimedicapp/navigation/tabs.dart';
import 'package:mimedicapp/pages/container/container_controller.dart';
import 'package:mimedicapp/pages/home/home_controller.dart';
import 'package:mimedicapp/pages/progreso/progreso_controller.dart';
import 'package:mimedicapp/pages/logros/logros_controller.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  AppTab current = AppTab.home;

  Future<void> _recargarTab(AppTab tab) async {
    if (tab == AppTab.home && Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().cargar();
    }

    if (tab == AppTab.progreso && Get.isRegistered<ProgresoController>()) {
      await Get.find<ProgresoController>().cargar();
    }

    if (tab == AppTab.logros && Get.isRegistered<LogrosController>()) {
      await Get.find<LogrosController>().cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContainerController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!controller.handleBack()) return;
        Get.back();
      },
      child: Scaffold(
        appBar: const Topbar(),
        body: IndexedStack(
          index: allTabs.indexOf(current),
          children: controller.views,
        ),
        bottomNavigationBar: Bottombar(
          current: current,
          onTap: (tab) async {
            setState(() => current = tab);
            await _recargarTab(tab);
          },
        ),
      ),
    );
  }
}