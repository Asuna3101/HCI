import 'package:flutter/material.dart';
import 'package:mimedicapp/models/appointment_reminder.dart';
import 'package:mimedicapp/widgets/status_badge.dart';

class ChangeStatusSheet extends StatefulWidget {
  final AppointmentStatus current;
  final void Function(AppointmentStatus) onConfirm;
  const ChangeStatusSheet({super.key, required this.current, required this.onConfirm});

  @override
  State<ChangeStatusSheet> createState() => _ChangeStatusSheetState();
}

class _ChangeStatusSheetState extends State<ChangeStatusSheet> {
  late AppointmentStatus _sel;

  @override
  void initState() {
    super.initState();
    _sel = widget.current;
  }

  Widget _opt(AppointmentStatus s) {
    return RadioListTile<AppointmentStatus>(
      value: s,
      groupValue: _sel,
      onChanged: (v) => setState(() => _sel = v!),
      title: Row(
        children: [
          StatusBadge(status: s, compact: true),
          const SizedBox(width: 10),
          Text(s.label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4))),
            const Text('Cambiar estado de la cita', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            _opt(AppointmentStatus.pendiente),
            _opt(AppointmentStatus.asistido),
            _opt(AppointmentStatus.noAsistido),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); widget.onConfirm(_sel); }, child: const Text('Guardar'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
