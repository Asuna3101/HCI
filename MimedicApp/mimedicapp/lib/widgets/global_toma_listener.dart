import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mimedicapp/repositories/toma_repository.dart';
import 'package:mimedicapp/models/toma.dart';
import 'package:mimedicapp/utils/event_bus.dart';

/// Widget que debe colocarse en la raíz de la aplicación (por ejemplo dentro
/// del `home` o del `Scaffold` principal) para vigilar tomas pendientes. Si
/// detecta tomas en el minuto exacto, muestra un AlertDialog global con dos
/// acciones: "Tomado" y "Recordar dentro de 5 minutos".
class GlobalTomaListener extends StatefulWidget {
  final TomaRepository repo;
  final Duration pollInterval;

  const GlobalTomaListener({Key? key, required this.repo, this.pollInterval = const Duration(minutes: 1)}) : super(key: key);

  @override
  State<GlobalTomaListener> createState() => _GlobalTomaListenerState();
}

class _GlobalTomaListenerState extends State<GlobalTomaListener> with WidgetsBindingObserver {
  Timer? _timer;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run once immediately, then periodically every minute
    _runCheck();
    _timer = Timer.periodic(widget.pollInterval, (_) => _runCheck());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Pause polling when app is in background to save battery
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _timer?.cancel();
      _timer = null;
    } else if (state == AppLifecycleState.resumed) {
      if (_timer == null) _timer = Timer.periodic(widget.pollInterval, (_) => _runCheck());
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _runCheck() async {
    try {
      // Use now UTC so backend can interpret correctly
      final now = DateTime.now().toUtc();
      final pendings = await widget.repo.getPendingTomas(at: now);
      if (pendings.isNotEmpty) {
        // show only one dialog at a time
        if (!_dialogShown && mounted) {
          // choose the first pending toma (assumed the current)
          final toma = pendings.first;
          _showTomaDialog(toma);
        }
      }
    } catch (e) {
      // ignore errors silently; polling must be resilient
      // ignore: avoid_print
      print('Error checking pending tomas: $e');
    }
  }

  Future<void> _showTomaDialog(Toma toma) async {
    _dialogShown = true;
    if (!mounted) return;

    // Ensure dialog displays above current UI
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Toma programada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tienes una toma programada ahora.'),
              const SizedBox(height: 8),
              Text('Hora: ${toma.adquired.toLocal()}'),
              const SizedBox(height: 8),
              // Show medication details
              Text('Medicamento: ${toma.medicamentoNombre}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Dosis: ${toma.dosis} ${toma.unidad}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Postpone by 5 minutes
                try {
                  await widget.repo.postponeTomas(toma.id, 5);
                  // notify UI that the toma was postponed so notifications page can show it
                  EventBus().emit({
                    'type': 'toma_event',
                    'action': 'postponed',
                    'tomaId': toma.id,
                    'medicamentoNombre': toma.medicamentoNombre,
                    'dosis': toma.dosis,
                    'unidad': toma.unidad,
                    'timestamp': DateTime.now().toUtc().toIso8601String(),
                  });
                } catch (e) {
                  // ignore errors, optionally show a SnackBar
                }
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Recordar dentro de 5 minutos'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await widget.repo.markTomado(toma.id, true);
                  // notify UI that the toma was marked as taken
                  EventBus().emit({
                    'type': 'toma_event',
                    'action': 'tomado',
                    'tomaId': toma.id,
                    'medicamentoNombre': toma.medicamentoNombre,
                    'dosis': toma.dosis,
                    'unidad': toma.unidad,
                    'timestamp': DateTime.now().toUtc().toIso8601String(),
                  });
                } catch (e) {
                  // ignore
                }
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Tomado'),
            ),
          ],
        );
      },
    );

    _dialogShown = false;
  }

  @override
  Widget build(BuildContext context) {
    // This widget is invisible; it only needs to exist in the widget tree to
    // manage the timer and show dialogs. It forwards its child's size if
    // necessary but here we just return an empty SizedBox.
    return const SizedBox.shrink();
  }
}
