import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/comidas/agregarComida/agregarComida_controller.dart';
import 'package:mimedicapp/pages/home/comidas/agregarComida/components/form_agregarComida.dart';

class AgregarComidaPage extends StatelessWidget {
  const AgregarComidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AgregarComidaController(), tag: 'agregar_comida');

    return Scaffold(
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Header(
                titulo: "Comidas",
                imagePath: "assets/img/homeIcons/comidas.png",
              ),
              const SizedBox(height: 30),
              Expanded(
                child: FormAgregarComida(controller: c),
              ),
            ],
          ),
        );
      }),
    );
  }
}
