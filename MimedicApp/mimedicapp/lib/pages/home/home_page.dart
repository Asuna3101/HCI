import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/home/components/habit_card.dart';
import 'package:mimedicapp/pages/home/components/progress_header.dart';
import 'package:mimedicapp/pages/home/home_controller.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return RefreshIndicator(
      onRefresh: controller.cargar,
      color: AppColors.accent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.saludo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat("EEEE, d 'de' MMMM", 'es_ES')
                        .format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() => ProgressHeader(
                  progreso: controller.progreso.value,
                  puntosHoy: controller.puntosHoy,
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hábitos de hoy',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Obx(() => Text(
                        '${controller.habitosCompletadosHoy.length}/${controller.habitos.length}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      )),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.cargando.value) {
              return const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habito = controller.habitos[index];
                  return Obx(() => HabitCard(
                        habit: habito,
                        completado: controller.habitosCompletadosHoy
                            .contains(habito.id),
                        procesando:
                            controller.procesando.contains(habito.id),
                        onTap: () => controller.toggleHabito(habito.id),
                      ));
                },
                childCount: controller.habitos.length,
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Obx(() {
              if (!controller.todosCompletados) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_rounded,
                        color: AppColors.gold, size: 28),
                    SizedBox(width: 10),
                    Text(
                      '¡Día perfecto! +20 pts extra',
                      style: TextStyle(
                        color: Color(0xFF7A6000),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
