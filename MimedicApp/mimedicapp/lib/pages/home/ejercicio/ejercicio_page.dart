import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/components/custom_button.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/ejercicio/components/ejercicioCard.dart';
import 'package:mimedicapp/pages/home/ejercicio/ejercicio_controller.dart';

class EjercicioPage extends StatelessWidget {
  const EjercicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EjercicioController());

    return WillPopScope(
      onWillPop: () async {
        Get.offNamed('/home/inicio',
            id: 1); // Volver al HomePage dentro del Navigator anidado
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
                        const Header(
                          titulo: "Ejercicios",
                          imagePath: "assets/img/homeIcons/ejercicios.png",
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => controller.goToAgregarEjercicio(),
                            icon: const Icon(Icons.add,
                                color: AppColors.primary, size: 28),
                            label: const Text(
                              'Agregar',
                              style: TextStyle(
                                fontFamily: 'Titulo',
                                fontSize: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        );
                      }

                      if (controller.ejerciciosUsuario.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No tienes ejercicios registrados.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 24,
                          bottom: 140, 
                        ),
                        child: Column(
                          children: controller.ejerciciosUsuario
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: EjercicioCard(
                                    ejercicio: e,
                                    onEdit: () =>
                                        controller.goToEditarEjercicio(e),
                                    selectionMode:
                                        controller.selectionMode.value,
                                    isSelected: e.id != null &&
                                        controller.selectedIds.contains(e.id),
                                    onToggleSelect: () =>
                                        controller.toggleSelect(e),
                                  ),
                                ),
                              )
                              .toList(),
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
                                    content: Text(
                                        '¿Eliminar ${controller.selectedIds.length} ejercicio(s)?'),
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
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
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
