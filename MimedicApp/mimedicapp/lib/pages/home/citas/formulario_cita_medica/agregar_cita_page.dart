import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'cita_form_page.dart';
import 'agregar_cita_form_controller.dart';

class AgregarCitaPage extends StatelessWidget {
  const AgregarCitaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciamos y registramos el controller en una variable local
    // ignore: avoid_print
    print('[AGREGAR CITA] Registrando AgregarCitaFormController y asignando a variable local');
    final controller = Get.put<AgregarCitaFormController>(
      AgregarCitaFormController(Get.find<HealthService>()),
    );
    // ignore: avoid_print
    print('[AGREGAR CITA] Controller registrado: ${controller.runtimeType}');

    return CitaFormPage(controller: controller);
  }
}
