import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimedicapp/configs/colors.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool activo = true;
  TimeOfDay hora = const TimeOfDay(hour: 8, minute: 0);

  final TextEditingController mensajeController =
      TextEditingController(text: '¡No olvides completar tus hábitos!');

  @override
  void dispose() {
    mensajeController.dispose();
    super.dispose();
  }

  Future<void> seleccionarHora() async {
    final t = await showTimePicker(
      context: context,
      initialTime: hora,
    );
    if (t != null) {
      setState(() => hora = t);
    }
  }

  void guardar() {
    Get.snackbar(
      'Recordatorio',
      activo
          ? 'Recordatorio configurado para las ${hora.format(context)}'
          : 'Los recordatorios están desactivados',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recordatorios'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: AppColors.card,
            child: SwitchListTile(
              value: activo,
              activeColor: AppColors.accent,
              title: Text(
                'Activar recordatorios',
                style: TextStyle(color: AppColors.text),
              ),
              subtitle: Text(
                'Recibir una notificación diaria',
                style: TextStyle(color: AppColors.subtitle),
              ),
              onChanged: (v) => setState(() => activo = v),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.access_time, color: AppColors.icon),
              title: Text(
                'Hora del recordatorio',
                style: TextStyle(color: AppColors.text),
              ),
              subtitle: Text(
                hora.format(context),
                style: TextStyle(color: AppColors.subtitle),
              ),
              onTap: activo ? seleccionarHora : null,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: mensajeController,
                enabled: activo,
                decoration: const InputDecoration(
                  labelText: 'Mensaje',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
