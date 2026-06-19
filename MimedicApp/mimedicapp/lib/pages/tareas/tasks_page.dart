import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/pages/tareas/tasks_controller.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(TasksController());

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: c.reload,
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (c.error.value != null) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.error_outline,
                    size: 38, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  c.error.value ?? 'No se pudieron cargar las tareas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: c.reload,
                  child: const Text('Reintentar'),
                )
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 8),
              const Text(
                'Tareas pendientes',
                style: TextStyle(
                  fontFamily: 'Titulo',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _CategoryBlock<TaskItem>(
                title: 'Ejercicio',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFEC407A),
                tasks: c.pendientes[TaskCategory.ejercicio] ?? const [],
                isPending: true,
                emptyLabel: 'No tienes ejercicios pendientes.',
              ),
              _CategoryBlock<TaskItem>(
                title: 'Medicamentos',
                icon: Icons.medication,
                color: const Color(0xFF5C6BC0),
                tasks: c.pendientes[TaskCategory.medicamentos] ?? const [],
                helper:
                    'Muestra tomas pendientes cercanas en el tiempo.',
                isPending: true,
                emptyLabel: 'Sin tomas pendientes ahora.',
              ),
              _CategoryBlock<TaskItem>(
                title: 'Citas',
                icon: Icons.event_available_rounded,
                color: const Color(0xFF26A69A),
                tasks: c.pendientes[TaskCategory.citas] ?? const [],
                isPending: true,
                emptyLabel: 'No tienes citas pendientes.',
              ),
              const SizedBox(height: 24),
              const Text(
                'Tareas completadas',
                style: TextStyle(
                  fontFamily: 'Titulo',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _CategoryBlock<TaskItem>(
                title: 'Ejercicio',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFEC407A),
                tasks: c.completadas[TaskCategory.ejercicio] ?? const [],
                emptyLabel: 'Aún no registras ejercicios completados.',
              ),
              _CategoryBlock<TaskItem>(
                title: 'Medicamentos',
                icon: Icons.medication,
                color: const Color(0xFF5C6BC0),
                tasks: c.completadas[TaskCategory.medicamentos] ?? const [],
                helper:
                    'Se actualiza cuando marcas una toma como tomada en notificaciones.',
                emptyLabel: 'Aún no registras tomas completadas.',
              ),
              _CategoryBlock<TaskItem>(
                title: 'Citas',
                icon: Icons.event_available_rounded,
                color: const Color(0xFF26A69A),
                tasks: c.completadas[TaskCategory.citas] ?? const [],
                emptyLabel: 'Aún no registras citas atendidas.',
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryBlock<T extends TaskItem> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<T> tasks;
  final String? helper;
  final String emptyLabel;
  final bool isPending;

  const _CategoryBlock({
    required this.title,
    required this.icon,
    required this.color,
    required this.tasks,
    this.helper,
    this.emptyLabel = 'Sin tareas en esta categoría.',
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tasks.length} ${isPending ? 'pendientes' : 'completadas'}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(
              helper!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          if (tasks.isEmpty)
            Text(
              emptyLabel,
              style: const TextStyle(fontSize: 14),
            )
          else
            Column(
              children: tasks
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: _TaskTile(task: t, color: color),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskItem task;
  final Color color;
  const _TaskTile({required this.task, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 10),
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (task.detail.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  task.detail,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _fmtDate(task.when),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (task.status != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.status!,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _fmtDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
