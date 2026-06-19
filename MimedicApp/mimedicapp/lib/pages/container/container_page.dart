import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/components/bottomBar.dart';
import 'package:mimedicapp/components/topBar.dart';
import 'package:mimedicapp/navigation/tabs.dart';
import 'package:mimedicapp/pages/container/container_controller.dart';

class ContainerPage extends StatefulWidget {
  const ContainerPage({super.key});

  @override
  State<ContainerPage> createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage> {
  AppTab current = AppTab.home;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContainerController());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final navigator = Get.nestedKey(1)?.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          // Si no hay más en stack, salir de la app
          Get.back();
        }
      },
      child: Scaffold(
        appBar: Topbar(),
        body: IndexedStack(
          index: allTabs.indexOf(current),
          children: controller.views,
        ),
        bottomNavigationBar: Bottombar(
          current: current,
          onTap: (tab) {
            if (tab == AppTab.home) {
              final navigator = Get.nestedKey(1)?.currentState;
              if (navigator != null) {
                navigator.popUntil((route) => route.isFirst);
              }
            }
            setState(() => current = tab);
          },
        ),
      ),
    );
  }
}
