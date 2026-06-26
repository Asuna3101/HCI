import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';
import 'package:mimedicapp/models/habit.dart';
import 'package:mimedicapp/pages/home/home_controller.dart';
import 'package:mimedicapp/services/api_service.dart';
import 'package:mimedicapp/services/habits_service.dart';

class ManageHabitsPage extends StatefulWidget {
  const ManageHabitsPage({super.key});

  @override
  State<ManageHabitsPage> createState() => _ManageHabitsPageState();
}

class _ManageHabitsPageState extends State<ManageHabitsPage> {
  final HabitsService service = HabitsService(ApiService());

  List<Habit> habitos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> sincronizarHome() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().cargar();
    }
  }

  Future<void> cargar() async {
    if (!mounted) return;
    setState(() => cargando = true);

    final data = await service.getHabitos();

    if (!mounted) return;
    setState(() {
      habitos = data;
      cargando = false;
    });
  }

  Future<void> abrirFormulario({Habit? habit}) async {
    final nombreCtrl = TextEditingController(text: habit?.nombre ?? '');
    final descripcionCtrl =
        TextEditingController(text: habit?.descripcion ?? '');
    final puntosCtrl =
        TextEditingController(text: '${habit?.puntosPorCompletar ?? 10}');
    String icono = habit?.icono ?? 'star';

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(habit == null ? 'Crear hábito' : 'Editar hábito'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: puntosCtrl,
                decoration: const InputDecoration(labelText: 'Puntos'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: icono,
                decoration: const InputDecoration(labelText: 'Icono'),
                items: const [
                  DropdownMenuItem(value: 'star', child: Text('⭐ General')),
                  DropdownMenuItem(value: 'water_drop', child: Text('💧 Agua')),
                  DropdownMenuItem(value: 'bedtime', child: Text('🌙 Sueño')),
                  DropdownMenuItem(
                    value: 'fitness_center',
                    child: Text('🏋️ Ejercicio'),
                  ),
                  DropdownMenuItem(
                    value: 'menu_book',
                    child: Text('📚 Lectura'),
                  ),
                  DropdownMenuItem(
                    value: 'self_improvement',
                    child: Text('🧘 Meditación'),
                  ),
                ],
                onChanged: (v) => icono = v ?? 'star',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final descripcion = descripcionCtrl.text.trim();
              final puntos = int.tryParse(puntosCtrl.text.trim()) ?? 10;

              if (nombre.isEmpty || descripcion.isEmpty) {
                Get.snackbar('Error', 'Completa todos los campos');
                return;
              }

              if (habit == null) {
                await service.crearHabito(
                  nombre: nombre,
                  descripcion: descripcion,
                  icono: icono,
                  puntos: puntos,
                );
              } else {
                await service.actualizarHabito(
                  id: habit.id,
                  nombre: nombre,
                  descripcion: descripcion,
                  icono: icono,
                  puntos: puntos,
                );
              }

              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }

              await cargar();
              await sincronizarHome();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );

    nombreCtrl.dispose();
    descripcionCtrl.dispose();
    puntosCtrl.dispose();
  }

  Future<void> eliminar(Habit habit) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Eliminar hábito'),
        content: Text('¿Deseas eliminar "${habit.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final ok = await service.eliminarHabito(habit.id);
      if (ok) {
        await cargar();
        await sincronizarHome();
        Get.snackbar('Hábito eliminado', 'Se eliminó correctamente');
      } else {
        Get.snackbar('Error', 'No se pudo eliminar el hábito');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar hábitos'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        onPressed: () => abrirFormulario(),
        icon: Icon(Icons.add),
        label: Text('Nuevo hábito'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargar,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: habitos.length,
                itemBuilder: (_, index) {
                  final h = habitos[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: h.color.withOpacity(0.15),
                        child: Icon(h.iconData, color: h.color),
                      ),
                      title: Text(
                        h.nombre,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text('${h.descripcion}\n${h.puntosPorCompletar} pts'),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: AppColors.primary,
                            ),
                            onPressed: () => abrirFormulario(habit: h),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => eliminar(h),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}