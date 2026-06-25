import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/achievement.dart';
import 'package:mimedicapp/pages/logros/logros_controller.dart';

class LogrosPage extends StatelessWidget {
  const LogrosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LogrosController>();

    return RefreshIndicator(
      onRefresh: controller.cargar,
      color: AppColors.accent,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis Logros',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        '${controller.desbloqueados} de ${controller.logros.length} desbloqueados',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      )),
                  const SizedBox(height: 16),
                  Obx(() => LinearProgressIndicator(
                        value: controller.logros.isEmpty
                            ? 0
                            : controller.desbloqueados /
                                controller.logros.length,
                        backgroundColor: AppColors.grey200,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.cargando.value) {
              return const SliverFillRemaining(
                child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _AchievementCard(
                    achievement: controller.logros[index],
                  ),
                  childCount: controller.logros.length,
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final desbloqueado = achievement.desbloqueado;

    return Container(
      decoration: BoxDecoration(
        color: desbloqueado ? AppColors.goldLight : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: desbloqueado
              ? AppColors.gold.withOpacity(0.6)
              : AppColors.grey200,
          width: desbloqueado ? 1.5 : 1,
        ),
        boxShadow: desbloqueado
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: desbloqueado
                      ? AppColors.gold.withOpacity(0.2)
                      : AppColors.grey200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icono,
                  size: 32,
                  color: desbloqueado ? AppColors.gold : Colors.grey[400],
                ),
              ),
              if (!desbloqueado)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.grey400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            achievement.nombre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: desbloqueado
                  ? const Color(0xFF7A6000)
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: desbloqueado ? const Color(0xFF9A7A00) : Colors.grey,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
