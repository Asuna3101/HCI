import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/comidas/editarComida/editarComida_controller.dart';
import 'package:mimedicapp/pages/home/comidas/agregarComida/components/form_agregarComida.dart';

class EditarComidaPage extends StatelessWidget {
  const EditarComidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EditarComidaController());

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
                titulo: "Editar comida",
                imagePath: "assets/img/homeIcons/comidas.png",
              ),
              const SizedBox(height: 30),
              Expanded(child: FormAgregarComida(controller: c)),
            ],
          ),
        );
      }),
    );
  }
}
