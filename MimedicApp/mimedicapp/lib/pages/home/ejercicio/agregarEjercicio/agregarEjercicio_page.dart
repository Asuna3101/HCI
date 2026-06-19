import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/ejercicio/agregarEjercicio/agregarEjercicio_controller.dart';
import 'package:mimedicapp/pages/home/ejercicio/components/formEjercicio.dart';

class AgregarEjercicioUsuarioPage extends StatelessWidget {
  const AgregarEjercicioUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AgregarEjercicioUsuarioController());

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
                titulo: "Ejercicios",
                imagePath: "assets/img/homeIcons/ejercicios.png",
              ),
              const SizedBox(height: 30),
              Expanded(
                child: FormEjercicioUsuario(controller: c),
              ),
            ],
          ),
        );
      }),
    );
  }
}
