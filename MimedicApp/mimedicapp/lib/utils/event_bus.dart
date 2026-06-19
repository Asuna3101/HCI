import 'dart:async';

/// Minimal app-wide event bus used to notify components about domain events
/// (e.g. toma fired, tomada, postponed). It's a simple wrapper around a
/// broadcast StreamController.
class EventBus {
  EventBus._internal();
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;

  final StreamController<Map<String, dynamic>> _ctrl = StreamController.broadcast();

  Stream<Map<String, dynamic>> get stream => _ctrl.stream;

  void emit(Map<String, dynamic> event) {
    try {
      _ctrl.add(event);
    } catch (_) {}
  }

  void dispose() {
    _ctrl.close();
  }
}
