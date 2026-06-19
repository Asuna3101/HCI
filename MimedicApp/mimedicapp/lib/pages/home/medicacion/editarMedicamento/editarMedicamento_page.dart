import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/medicacion/editarMedicamento/editarMedicamento_controller.dart';
import 'package:mimedicapp/pages/home/medicacion/agregarMedicamento/components/form_agregarMedicamento.dart';

class EditarMedicamentoPage extends StatelessWidget {
  const EditarMedicamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EditarMedicamentoController());

    return Scaffold(
      body: Obx(() {
        if (c.isLoading.value) return const Center(child: CircularProgressIndicator());
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Header(
                titulo: "Editar medicación",
                imagePath: "assets/img/homeIcons/medicamentos.png",
              ),
              const SizedBox(height: 30),
              Expanded(child: FormAgregarMedicamento(controller: c)),
            ],
          ),
        );
      }),
    );
  }
}