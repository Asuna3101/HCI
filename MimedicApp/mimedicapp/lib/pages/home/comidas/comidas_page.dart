import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/components/custom_button.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/home/components/header.dart';
import 'package:mimedicapp/pages/home/comidas/comidas_controller.dart';
import 'components/comida_card.dart';

class ComidasPage extends StatelessWidget {
  const ComidasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComidasController(), tag: 'comidas_list');

    return WillPopScope(
      onWillPop: () async {
        Get.delete<ComidasController>(tag: 'comidas_list');
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
                        const Header(
                          titulo: "Comidas",
                          imagePath: "assets/img/homeIcons/comidas.png",
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => controller.goToAgregarComida(),
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

                      if (controller.comidas.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No hay comidas registradas.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: controller.comidas
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ComidaCard(
                                    comida: c,
                                    onEdit: () =>
                                        controller.goToEditarComida(c),
                                    selectionMode:
                                        controller.selectionMode.value,
                                    isSelected: c.id != null &&
                                        controller.selectedIds.contains(c.id),
                                    onToggleSelect: () =>
                                        controller.toggleSelect(c),
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
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text(
                                        '¿Eliminar ${controller.selectedIds.length} comida(s)?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
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
