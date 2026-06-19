import 'package:mimedicapp/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/home/citas/components/cita_card.dart';
import 'package:mimedicapp/pages/home/citas/citas_controller.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/home_routes.dart';
import 'package:mimedicapp/services/health_service.dart';

class CitasPage extends StatelessWidget {
  const CitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CitasListController(Get.find<HealthService>()));

    return WillPopScope(
      onWillPop: () async {
        Get.offNamed('/home/inicio', id: 1);
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Header(titulo: "Citas", imagePath: "assets/img/homeIcons/citas.png"),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final created = await Get.toNamed(HomeRoutes.agregarCita, id: 1);
                          if (created == true) controller.cargar();
                        },
                        icon: const Icon(Icons.add, color: AppColors.primary, size: 28),
                        label: const Text('Agregar',
                          style: TextStyle(fontFamily: 'Titulo', fontSize: 18, color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Proximas citas
              Expanded(
                child: Obx(() {
                  if (controller.cargando.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  final proximas = controller.proximas;
                  if (proximas.isEmpty) return const _Empty();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 12, bottom: 12),
                          child: Text(
                            "Próximas Citas",
                            style: TextStyle(
                              fontFamily: 'Titulo',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        ...proximas.map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CitaMedicaCard(
                                cita: r,
                                onEdit: () async {
                                  await controller.goEditarCita(r);
                                },
                                selectionMode: controller.selectionMode.value,
                                isSelected: controller.selectedIds.contains(r.id),
                                onToggleSelect: () => controller.toggleSelect(r),
                              ),
                            )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }),
              ),
              ],
              ),

              // Botón fijo en la parte inferior
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 200,
                    child: Obx(() {
                      final inSelection = controller.selectionMode.value;
                      return CustomButton(
                        title: inSelection ? 'Eliminar' : 'Eliminar',
                        onPressed: inSelection
                            ? () async {
                                // Mostrar confirmación antes de eliminar
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text('¿Eliminar ${controller.selectedIds.length} cita(s)?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          // Salir del modo selección y cerrar diálogo
                                          controller.toggleSelectionMode();
                                          Navigator.of(ctx).pop(false);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  controller.deleteSelected();
                                }
                              }
                            : () => controller.toggleSelectionMode(),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy, size: 56, color: AppColors.primary),
              SizedBox(height: 10),
              Text('No tienes citas registradas',
                  style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('Pulsa “Agregar” para registrar tu próxima cita.',
                  style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
      );
}
