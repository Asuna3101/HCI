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
                  Text(
                    'Mis Logros',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        '${controller.desbloqueados} de ${controller.logros.length} desbloqueados',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 14,
                        ),
                      )),
                  const SizedBox(height: 16),
                  Obx(() {
                    final total = controller.logros.length;
                    final value =
                        total == 0 ? 0.0 : controller.desbloqueados / total;

                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: value),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedValue, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: animatedValue,
                            backgroundColor: AppColors.progressBackground,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              AppColors.gold,
                            ),
                            minHeight: 8,
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.cargando.value) {
              return SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color : AppColors.text,
                  ),
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
                  (context, index) => _AnimatedAchievementCard(
                    index: index,
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

class _AnimatedAchievementCard extends StatelessWidget {
  final int index;
  final Achievement achievement;

  const _AnimatedAchievementCard({
    required this.index,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final safeValue = value.clamp(0.0, 1.0);

        return Opacity(
          opacity: safeValue,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - safeValue)),
            child: Transform.scale(
              scale: 0.92 + (0.08 * safeValue),
              child: child,
            ),
          ),
        );
      },
      child: _AchievementCard(achievement: achievement),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final desbloqueado = achievement.desbloqueado;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: desbloqueado
            ? LinearGradient(
                colors: [
                  AppColors.goldLight,
                  AppColors.gold.withOpacity(0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: desbloqueado ? null : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: desbloqueado
              ? AppColors.gold.withOpacity(0.8)
               : AppColors.border,
          width: desbloqueado ? 1.7 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: desbloqueado
                ? AppColors.gold.withOpacity(0.25)
                : Colors.black.withOpacity(AppColors.isDark ? 0.25 : 0.04),
            blurRadius: desbloqueado ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: desbloqueado
                        ? AppColors.gold.withOpacity(0.22)
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icono,
                    size: 34,
                    color: desbloqueado ? AppColors.gold : AppColors.subtitle,
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
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (desbloqueado)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              color: desbloqueado
                  ? const Color(0xFF9A7A00)
                   : AppColors.subtitle,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}