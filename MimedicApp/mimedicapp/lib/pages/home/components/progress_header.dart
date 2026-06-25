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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel ${progreso.nivel} · ${progreso.nombreNivel}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${progreso.puntosTotal} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _RachaChip(racha: progreso.rachaActual),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progreso.progresoNivel,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          if (progreso.nivel < 5) ...[
            const SizedBox(height: 4),
            Text(
              '${progreso.puntosParaSiguienteNivel} pts para el siguiente nivel',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
          if (puntosHoy > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
              ),
              child: Text(
                '+$puntosHoy pts hoy',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RachaChip extends StatelessWidget {
  final int racha;
  const _RachaChip({required this.racha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department_rounded,
              color: Colors.orange, size: 22),
          Text(
            '$racha',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Text('días', style: TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}
