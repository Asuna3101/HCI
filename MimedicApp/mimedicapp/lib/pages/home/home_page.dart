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
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat("EEEE, d 'de' MMMM", 'es_ES')
                        .format(DateTime.now()),
                    style: TextStyle(
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
            child: Obx(
              () => _RecommendationCard(
                titulo: controller.recomendacionTitulo,
                mensaje: controller.recomendacionMensaje,
                accion: controller.recomendacionAccion,
                progreso: controller.porcentajeHoy,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hábitos de hoy',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Obx(() => Text(
                        '${controller.habitosCompletadosHoy.length}/${controller.habitos.length}',
                        style: TextStyle(
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
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habito = controller.habitos[index];

                  return Obx(
                    () => HabitCard(
                      habit: habito,
                      completado:
                          controller.habitosCompletadosHoy.contains(habito.id),
                      procesando: controller.procesando.contains(habito.id),
                      onTap: () => controller.toggleHabito(habito.id),
                    ),
                  );
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
                    Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
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

class _RecommendationCard extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String accion;
  final double progreso;

  const _RecommendationCard({
    required this.titulo,
    required this.mensaje,
    required this.accion,
    required this.progreso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accent,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recomendación inteligente',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mensaje,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progreso.clamp(0.0, 1.0),
                    minHeight: 7,
                    backgroundColor: AppColors.grey200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  accion,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}