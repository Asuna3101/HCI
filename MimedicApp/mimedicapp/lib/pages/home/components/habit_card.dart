import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool completado;
  final bool procesando;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.completado,
    required this.procesando,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: completado ? 0.96 : 1,
        end: 1,
      ),
      duration: const Duration(milliseconds: 320),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: completado
              ? habit.color.withOpacity(0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completado
                ? habit.color
                : AppColors.border,
            width: completado ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: completado
                  ? habit.color.withOpacity(0.18)
                  : Colors.black.withOpacity(
                      AppColors.isDark ? 0.35 : 0.05,
                    ),
              blurRadius: completado ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: procesando ? null : onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _HabitIcon(
                    habit: habit,
                    completado: completado,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration:
                              const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: completado
                                ? habit.color
                                : AppColors.text,
                          ),
                          child: Text(habit.nombre),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          habit.descripcion,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CheckButton(
                    completado: completado,
                    procesando: procesando,
                    color: habit.color,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitIcon extends StatelessWidget {
  final Habit habit;
  final bool completado;

  const _HabitIcon({
    required this.habit,
    required this.completado,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: habit.color.withOpacity(
          completado ? 0.25 : 0.12,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          );
        },
        child: Icon(
          completado
              ? Icons.check_rounded
              : habit.iconData,
          key: ValueKey(completado),
          color: habit.color,
          size: 26,
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final bool completado;
  final bool procesando;
  final Color color;
  final VoidCallback onTap;

  const _CheckButton({
    required this.completado,
    required this.procesando,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (procesando) {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: completado ? 34 : 30,
        height: completado ? 34 : 30,
        decoration: BoxDecoration(
          color: completado
              ? color
              : AppColors.surface,
          border: Border.all(
            color: completado
                ? color
                : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: completado
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: child,
            );
          },
          child: completado
              ? Icon(
                  Icons.check_rounded,
                  key: ValueKey('checked'),
                  color: Colors.white,
                  size: 20,
                )
              : const SizedBox(
                  key: ValueKey('unchecked'),
                ),
        ),
      ),
    );
  }
}