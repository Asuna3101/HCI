import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/services/health_service.dart';
import 'cita_form_page.dart';
import 'editar_cita_form_controller.dart';

class EditarCitaPage extends StatelessWidget {
  const EditarCitaPage({super.key});

  @override
  Widget build(BuildContext context) {
  // Obtener el reminder pasado por argumentos.
  // Usamos ModalRoute.settings.arguments primero (más fiable dentro de Navigator),
  // y fallback a Get.arguments si está disponible.
  final routeArg = ModalRoute.of(context)?.settings.arguments;
  final rawArg = routeArg ?? Get.arguments;
  // Log para depuración: ver qué trae cada fuente
  // ignore: avoid_print
  print('[EDITAR] ModalRoute.arguments: $routeArg');
  // ignore: avoid_print
  print('[EDITAR] Get.arguments raw: ${Get.arguments}');
  final AppointmentReminder? reminder = rawArg is AppointmentReminder ? rawArg : null;
  // ignore: avoid_print
  print('[EDITAR] resolved reminder: ${reminder == null ? 'null' : reminder.id}');

    if (reminder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar cita')),
        body: const Center(child: Text('No se recibió la cita para editar')),
      );
    }

    // Registramos el controller usando su tipo concreto (EditarCitaFormController).
    print('[EDITAR] Creando EditarCitaFormController para el reminder ${reminder.id}');
    final controller = Get.put<EditarCitaFormController>(
      EditarCitaFormController(Get.find<HealthService>(), reminder),
    );
    // ignore: avoid_print
    print('[EDITAR] Controller registrado: ${controller.runtimeType}');

    return CitaFormPage(controller: controller);
  }
}