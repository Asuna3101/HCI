import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/progreso/calendar_page.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mi progreso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              IconButton(
                tooltip: 'Calendario',
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Get.to(() => const CalendarPage()),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos 7 días',
            style: TextStyle(color: AppColors.subtitle, fontSize: 14),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => Get.to(() => const CalendarPage()),
            icon: Icon(Icons.calendar_month_rounded),
            label: Text('Ver calendario de hábitos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
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

            final datos = List<Map<String, dynamic>>.from(
              controller.datosSemanales,
            );

            return Column(
              children: [
                _DashboardAvanzado(controller: controller),
                const SizedBox(height: 20),
                _FeedbackCard(texto: controller.feedbackInteligente),
                const SizedBox(height: 24),
                _GraficoSemanal(
                  datos: datos,
                  maxY: controller.maxCompletados(),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Obx(() {
            final datos = List<Map<String, dynamic>>.from(
              controller.datosSemanales,
            );
            return _ResumenSemanal(datos: datos);
          }),
        ],
      ),
    );
  }
}

class _DashboardAvanzado extends StatelessWidget {
  final ProgresoController controller;

  const _DashboardAvanzado({required this.controller});

  @override
  Widget build(BuildContext context) {
    final porcentaje =
        (controller.porcentajeCumplimiento * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard avanzado',
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
                label: 'Cumplimiento',
                value: '$porcentaje%',
                subtitle: 'semanal',
                icon: Icons.percent_rounded,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Días activos',
                value: '${controller.diasActivos}',
                subtitle: 'de 7 días',
                icon: Icons.calendar_today_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Promedio diario',
                value: controller.promedioDiario.toStringAsFixed(1),
                subtitle: 'hábitos/día',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Mejor día',
                value: controller.mejorDiaNombre,
                subtitle: '${controller.mejorDiaCantidad} hábitos',
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

class _FeedbackCard extends StatelessWidget {
  final String texto;

  const _FeedbackCard({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.psychology_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback inteligente',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _GraficoSemanal extends StatelessWidget {
  final List<Map<String, dynamic>> datos;
  final double maxY;

  const _GraficoSemanal({
    required this.datos,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppColors.isDark ? 0.35 : 0.06),
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
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} hábitos',
                  TextStyle(
                    color: AppColors.card,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
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

                  final fecha = DateTime.parse(
                    datos[index]['fecha'] as String,
                  );

                  const dias = [
                    'Lun',
                    'Mar',
                    'Mié',
                    'Jue',
                    'Vie',
                    'Sáb',
                    'Dom',
                  ];

                  return Text(
                    dias[fecha.weekday - 1],
                    style: TextStyle(
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
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.subtitle,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 20,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) {
              return FlLine(
                color: AppColors.divider,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: List.generate(datos.length, (i) {
            final completados =
                (datos[i]['completados'] as int? ?? 0).toDouble();
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
                    top: Radius.circular(8),
                  ),
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
      0,
      (sum, d) => sum + (d['completados'] as int? ?? 0),
    );

    final totalPosibles = datos.fold<int>(
      0,
      (sum, d) => sum + (d['total'] as int? ?? 5),
    );

    final diasPerfectos = datos.where((d) {
      final completados = d['completados'] as int? ?? 0;
      final total = d['total'] as int? ?? 5;
      return total > 0 && completados >= total;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
      height: 132,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(AppColors.isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0,4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.text,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.subtitle, fontSize: 11),
          ),
        ],
      ),
    );
  }
}