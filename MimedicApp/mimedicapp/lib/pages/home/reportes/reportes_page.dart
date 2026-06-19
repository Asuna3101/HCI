import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/report_event.dart';
import 'package:mimedicapp/pages/home/reportes/reportes_controller.dart';
import 'package:mimedicapp/widgets/report_download_sheet.dart';
import 'dart:convert';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportesController());

    return WillPopScope(
      onWillPop: () async {
        Get.offNamed('/home/inicio', id: 1);
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
            if (c.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (c.error.value != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.primary, size: 38),
                      const SizedBox(height: 12),
                      Text(
                        c.error.value ?? 'No se pudo cargar',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: c.cargar,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final grouped = _groupByDay(c.eventos);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _TitleRow(
                    title: "Reportes y seguimiento",
                    imagePath: "assets/img/homeIcons/reportes.png",
                  ),
                  const SizedBox(height: 20),
                  _UserCard(
                    nombre: c.nombre.value,
                    fechaNacimiento: c.fechaNacimiento.value,
                    fotoBase64: c.fotoBase64.value,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informe por módulo',
                    style: TextStyle(
                      fontFamily: 'Titulo',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._moduleSummaries(c.modulos, c),
                  const SizedBox(height: 24),
                  const Text(
                    'Línea de tiempo (agrupada por día)',
                    style: TextStyle(
                      fontFamily: 'Titulo',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (grouped.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Sin eventos registrados aún.',
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  else
                    Column(
                      children: grouped.entries.map((entry) {
                        return _DayGroup(
                          dayLabel: entry.key,
                          events: entry.value,
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String nombre;
  final DateTime? fechaNacimiento;
  final String fotoBase64;
  const _UserCard({required this.nombre, required this.fechaNacimiento, required this.fotoBase64});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _Avatar(fotoBase64: fotoBase64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre.isEmpty ? 'Usuario' : nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (fechaNacimiento != null)
                  Row(
                    children: [
                      const Icon(Icons.cake_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        _fmtDate(fechaNacimiento!),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String fotoBase64;
  const _Avatar({required this.fotoBase64});
  @override
  Widget build(BuildContext context) {
    if (fotoBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(fotoBase64);
        return CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: MemoryImage(bytes),
          key: ValueKey(fotoBase64.length),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 32,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: const Icon(Icons.person, size: 32, color: AppColors.primary),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final ReportEventModel event;
  const _TimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(event.type);
    final icon = _typeIcon(event.type);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            Container(
              width: 2,
              height: 40,
              color: color.withOpacity(0.2),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fmtDate(event.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  event.subtitle,
                  style: const TextStyle(fontSize: 14),
                ),
                if (event.status != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      event.status!,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Color _typeColor(ReportEventType type) {
  switch (type) {
    case ReportEventType.registro:
      return AppColors.primary;
    case ReportEventType.medicacion:
      return const Color(0xFF5C6BC0);
    case ReportEventType.toma:
      return const Color(0xFF7E57C2);
    case ReportEventType.cita:
      return const Color(0xFF26A69A);
    case ReportEventType.comida:
      return const Color(0xFFF9A825);
    case ReportEventType.ejercicio:
      return const Color(0xFFEC407A);
  }
}

IconData _typeIcon(ReportEventType type) {
  switch (type) {
    case ReportEventType.registro:
      return Icons.flag_rounded;
    case ReportEventType.medicacion:
      return Icons.medication_liquid;
    case ReportEventType.toma:
      return Icons.timer_outlined;
    case ReportEventType.cita:
      return Icons.event_available_rounded;
    case ReportEventType.comida:
      return Icons.restaurant_menu_rounded;
    case ReportEventType.ejercicio:
      return Icons.fitness_center_rounded;
  }
}

String _fmtDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

Map<String, List<ReportEventModel>> _groupByDay(List<ReportEventModel> events) {
  final Map<String, List<ReportEventModel>> grouped = {};
  for (final e in events) {
    final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(e);
  }
  for (final list in grouped.values) {
    list.sort((a, b) => b.date.compareTo(a.date));
  }
  final sortedKeys = grouped.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // desc
  return {for (final k in sortedKeys) k: grouped[k]!};
}

List<Widget> _moduleSummaries(
    Map<ReportEventType, List<ReportEventModel>> modules, ReportesController c) {
  const labels = <ReportEventType, String>{
    ReportEventType.medicacion: 'Medicación',
    ReportEventType.toma: 'Tomas',
    ReportEventType.cita: 'Citas',
    ReportEventType.comida: 'Comidas',
    ReportEventType.ejercicio: 'Ejercicio',
  };

  return labels.entries.map((entry) {
    final filtered = modules[entry.key] ?? const [];
    final last = filtered.isNotEmpty ? filtered.first : null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_typeIcon(entry.key), color: _typeColor(entry.key)),
              const SizedBox(width: 12),
              Text(
                entry.value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${filtered.length} eventos',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                color: _typeColor(entry.key),
                tooltip: 'Ver/descargar',
                onPressed: () async {
                  showModalBottomSheet(
                    context: Get.context!,
                    builder: (_) => ReportDownloadSheet(type: entry.key),
                  );
                },
              )
            ],
          ),
          if (last != null) ...[
            const SizedBox(height: 8),
            Text(
              'Último: ${last.title}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _fmtDate(last.date),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filtered
                  .take(3)
                  .map(
                    (e) => Chip(
                      label: Text(
                        e.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _typeColor(entry.key).withOpacity(0.08),
                      labelStyle: TextStyle(color: _typeColor(entry.key)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }).toList();
}

class _DayGroup extends StatefulWidget {
  final String dayLabel;
  final List<ReportEventModel> events;
  const _DayGroup({required this.dayLabel, required this.events});

  @override
  State<_DayGroup> createState() => _DayGroupState();
}

class _TitleRow extends StatelessWidget {
  final String title;
  final String imagePath;
  const _TitleRow(
      {required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 64),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Titulo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayGroupState extends State<_DayGroup> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: (v) => setState(() => expanded = v),
        title: Text(
          widget.dayLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${widget.events.length} eventos',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: widget.events
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _TimelineTile(event: e),
                ))
            .toList(),
      ),
    );
  }
}
