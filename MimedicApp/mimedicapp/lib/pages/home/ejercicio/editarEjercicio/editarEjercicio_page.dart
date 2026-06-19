import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/ejercicio/editarEjercicio/editarEjercicio_controller.dart';
import 'package:mimedicapp/pages/home/ejercicio/components/formEjercicio.dart';

class EditarEjercicioUsuarioPage extends StatelessWidget {
  const EditarEjercicioUsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EditarEjercicioUsuarioController());

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
                titulo: "Editar ejercicio",
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
