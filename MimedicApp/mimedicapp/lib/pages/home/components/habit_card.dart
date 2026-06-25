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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: completado
            ? habit.color.withOpacity(0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completado ? habit.color : AppColors.grey200,
          width: completado ? 1.5 : 1,
        ),
        boxShadow: completado
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _HabitIcon(habit: habit, completado: completado),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: completado
                              ? habit.color
                              : AppColors.primary,
                          decoration: completado
                              ? TextDecoration.none
                              : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habit.descripcion,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
    );
  }
}

class _HabitIcon extends StatelessWidget {
  final Habit habit;
  final bool completado;

  const _HabitIcon({required this.habit, required this.completado});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: habit.color.withOpacity(completado ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        completado ? Icons.check_rounded : habit.iconData,
        color: habit.color,
        size: 26,
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
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: completado ? color : Colors.transparent,
          border: Border.all(
            color: completado ? color : AppColors.grey400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: completado
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
