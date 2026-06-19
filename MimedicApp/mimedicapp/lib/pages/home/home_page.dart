import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/components/home_card.dart';
import 'package:mimedicapp/pages/home/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, 
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.9,
                children: [
                  HomeCard(
                    title: "Medicación",
                    imagePath: 'assets/img/homeIcons/medicamentos.png',
                    onTap: controller.goToMedicacion,
                  ),
                  HomeCard(
                    title: "Citas",
                    imagePath: 'assets/img/homeIcons/citas.png',
                    onTap: controller.goToCitas,
                  ),
                  HomeCard(
                    title: "Comidas",
                    imagePath: 'assets/img/homeIcons/comidas.png',
                    onTap: controller.goToComidas,
                  ),
                  HomeCard(
                    title: "Ejercicio",
                    imagePath: 'assets/img/homeIcons/ejercicios.png',
                    onTap: controller.goToEjercicio
                  ),
                  HomeCard(
                    title: "Reportes y seguimiento",
                    imagePath: 'assets/img/homeIcons/reportes.png',
                    onTap: controller.goToReportes
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
