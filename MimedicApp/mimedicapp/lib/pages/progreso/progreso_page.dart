import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/progreso/progreso_controller.dart';

class ProgresoPage extends StatelessWidget {
  const ProgresoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProgresoController>();

    return RefreshIndicator(
      onRefresh: controller.cargar,
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Mi progreso',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Últimos 7 días',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.cargando.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            return _GraficoSemanal(controller: controller);
          }),
          const SizedBox(height: 24),
          Obx(() => _ResumenSemanal(datos: controller.datosSemanales)),
        ],
      ),
    );
  }
}

class _GraficoSemanal extends StatelessWidget {
  final ProgresoController controller;

  const _GraficoSemanal({required this.controller});

  @override
  Widget build(BuildContext context) {
    final datos = controller.datosSemanales;
    final maxY = controller.maxCompletados();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY + 1,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                '${rod.toY.toInt()} hábitos',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= datos.length) {
                    return const SizedBox.shrink();
                  }
                  final fecha =
                      DateTime.parse(datos[index]['fecha'] as String);
                  const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                  return Text(
                    dias[fecha.weekday - 1],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                reservedSize: 20,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.grey200,
              strokeWidth: 1,
            ),
          ),
          barGroups: List.generate(datos.length, (i) {
            final completados = (datos[i]['completados'] as int? ?? 0).toDouble();
            final total = (datos[i]['total'] as int? ?? 5).toDouble();
            final esDiaPerfecto = completados >= total;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: completados,
                  color: esDiaPerfecto ? AppColors.gold : AppColors.primary,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _ResumenSemanal extends StatelessWidget {
  final List<Map<String, dynamic>> datos;

  const _ResumenSemanal({required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const SizedBox.shrink();

    final totalCompletados = datos.fold<int>(
        0, (sum, d) => sum + (d['completados'] as int? ?? 0));
    final totalPosibles = datos.fold<int>(
        0, (sum, d) => sum + (d['total'] as int? ?? 5));
    final diasPerfectos = datos
        .where((d) =>
            (d['completados'] as int? ?? 0) >= (d['total'] as int? ?? 5))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen semanal',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Completados',
                value: '$totalCompletados',
                subtitle: 'de $totalPosibles posibles',
                icon: Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Días perfectos',
                value: '$diasPerfectos',
                subtitle: 'de 7 días',
                icon: Icons.emoji_events_rounded,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
