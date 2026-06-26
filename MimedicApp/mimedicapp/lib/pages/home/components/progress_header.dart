import 'package:flutter/material.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/user_progress.dart';

class ProgressHeader extends StatelessWidget {
  final UserProgress progreso;
  final int puntosHoy;

  const ProgressHeader({
    super.key,
    required this.progreso,
    required this.puntosHoy,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF6A1B9A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(
              AppColors.isDark ? 0.45 : 0.30,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel ${progreso.nivel} · ${progreso.nombreNivel}',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: progreso.puntosTotal.toDouble(),
                    ),
                    duration: const Duration(
                      milliseconds: 600,
                    ),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return Text(
                        '${value.round()} pts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              _RachaChip(
                racha: progreso.rachaActual,
              ),
            ],
          ),

          const SizedBox(height: 12),

          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: progreso.progresoNivel.clamp(0.0, 1.0),
            ),
            duration: const Duration(
              milliseconds: 650,
            ),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor:
                      AppColors.progressBackground,
                  valueColor:
                      const AlwaysStoppedAnimation(
                    AppColors.gold,
                  ),
                ),
              );
            },
          ),

          if (progreso.nivel < 5) ...[
            const SizedBox(height: 6),
            Text(
              '${progreso.puntosParaSiguienteNivel} pts para el siguiente nivel',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],

          AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 300,
            ),
            child: puntosHoy > 0
                ? Container(
                    key: ValueKey(puntosHoy),
                    margin:
                        const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.gold.withOpacity(0.18),
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold
                            .withOpacity(0.45),
                      ),
                    ),
                    child: Text(
                      '+$puntosHoy pts hoy',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RachaChip extends StatelessWidget {
  final int racha;

  const _RachaChip({
    required this.racha,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0.95,
        end: 1,
      ),
      duration: const Duration(
        milliseconds: 500,
      ),
      curve: Curves.elasticOut,
      builder: (_, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.isDark
              ? Colors.white10
              : Colors.white12,
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.isDark
                ? Colors.white12
                : Colors.white24,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 22,
            ),
            Text(
              '$racha',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'días',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}