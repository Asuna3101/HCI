import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/habit.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'package:mimedicapp/services/habits_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final HabitsService service = HabitsService(ApiService());

  bool cargando = true;
  List<Map<String, dynamic>> datos = [];
  List<Habit> habitos = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() => cargando = true);

    final data = await service.getProgresoMensual();
    final habitsData = await service.getHabitos();

    if (!mounted) return;

    setState(() {
      datos = data;
      habitos = habitsData;
      cargando = false;
    });
  }

  Map<String, dynamic>? datoPorFecha(DateTime fecha) {
    final key = _formatFecha(fecha);
    try {
      return datos.firstWhere((d) => d['fecha'] == key);
    } catch (_) {
      return null;
    }
  }

  String _formatFecha(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _fechaBonita(DateTime d) {
    return '${d.day} de ${_nombreMes(d.month).toLowerCase()}';
  }

  Color colorDia(DateTime fecha) {
    final dato = datoPorFecha(fecha);
    if (dato == null) return AppColors.grey200;

    final completados = dato['completados'] as int? ?? 0;
    final total = dato['total'] as int? ?? 0;

    if (completados == 0) return AppColors.grey200;
    if (total > 0 && completados >= total) return AppColors.success;
    return AppColors.warning;
  }

  void mostrarDetalle(DateTime fecha) {
    final dato = datoPorFecha(fecha);
    final completados = dato?['completados'] as int? ?? 0;
    final total = dato?['total'] as int? ?? habitos.length;
    final esPerfecto = total > 0 && completados >= total;
    final puntos = esPerfecto ? (completados * 10) + 20 : completados * 10;

    final List<Habit> completadosLista = habitos.take(completados).toList();
    final List<Habit> pendientesLista = habitos.skip(completados).toList();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          _fechaBonita(fecha),
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 360,
          child: completados == 0
              ? Text(
                  'No registraste hábitos en esta fecha.',
                  style: TextStyle(color: Colors.black54),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completaste $completados de $total hábitos.',
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      ...completadosLista.map(
                        (h) => _HabitDetailRow(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.success,
                          text: h.nombre,
                        ),
                      ),

                      ...pendientesLista.map(
                        (h) => _HabitDetailRow(
                          icon: Icons.cancel_rounded,
                          iconColor: AppColors.grey400,
                          text: h.nombre,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Divider(),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Puntos obtenidos: +$puntos pts',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (esPerfecto) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                color: AppColors.gold,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Día perfecto',
                                  style: TextStyle(
                                    color: Color(0xFF7A6000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final primerDiaMes = DateTime(hoy.year, hoy.month, 1);
    final ultimoDiaMes = DateTime(hoy.year, hoy.month + 1, 0);
    final offset = primerDiaMes.weekday - 1;
    final totalCeldas = offset + ultimoDiaMes.day;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Calendario de hábitos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: cargar,
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF6A1B9A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vista mensual',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_nombreMes(hoy.month)} ${hoy.year}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Revisa tu constancia durante el mes.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Leyenda(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _DiaSemana('L'),
                      _DiaSemana('M'),
                      _DiaSemana('M'),
                      _DiaSemana('J'),
                      _DiaSemana('V'),
                      _DiaSemana('S'),
                      _DiaSemana('D'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalCeldas,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (_, index) {
                      if (index < offset) return const SizedBox.shrink();

                      final dia = index - offset + 1;
                      final fecha = DateTime(hoy.year, hoy.month, dia);
                      final color = colorDia(fecha);
                      final esHoy = dia == hoy.day;

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => mostrarDetalle(fecha),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: esHoy ? AppColors.primary : color,
                              width: esHoy ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$dia',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color == AppColors.grey200
                                    ? Colors.grey
                                    : color,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  String _nombreMes(int mes) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return meses[mes - 1];
  }
}

class _HabitDetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _HabitDetailRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LeyendaItem(color: AppColors.success, texto: 'Día perfecto'),
        _LeyendaItem(color: AppColors.warning, texto: 'Parcial'),
        _LeyendaItem(color: AppColors.grey200, texto: 'Sin registro'),
      ],
    );
  }
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String texto;

  const _LeyendaItem({
    required this.color,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(fontSize: 12, color: AppColors.subtitle),
        ),
      ],
    );
  }
}

class _DiaSemana extends StatelessWidget {
  final String texto;

  const _DiaSemana(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}