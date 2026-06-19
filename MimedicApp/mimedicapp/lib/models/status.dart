import 'package:flutter/material.dart';

/// Clase base abstracta para todos los tipos de estados en la aplicación
abstract class Status {
  /// Etiqueta de texto para mostrar el estado
  String get label;
  
  /// Color asociado al estado
  Color color(BuildContext context);
}

/// Estados de citas médicas
enum AppointmentStatusType { pendiente, asistido, noAsistido }

class AppointmentStatus extends Status {
  final AppointmentStatusType type;
  
  AppointmentStatus._(this.type);
  
  static final pendiente = AppointmentStatus._(AppointmentStatusType.pendiente);
  static final asistido = AppointmentStatus._(AppointmentStatusType.asistido);
  static final noAsistido = AppointmentStatus._(AppointmentStatusType.noAsistido);
  
  @override
  String get label {
    switch (type) {
      case AppointmentStatusType.asistido:
        return 'Asistido';
      case AppointmentStatusType.noAsistido:
        return 'No asistido';
      case AppointmentStatusType.pendiente:
        return 'Pendiente';
    }
  }
  
  @override
  Color color(BuildContext context) {
    switch (type) {
      case AppointmentStatusType.asistido:
        return Colors.green;
      case AppointmentStatusType.noAsistido:
        return Colors.redAccent;
      case AppointmentStatusType.pendiente:
        return Theme.of(context).colorScheme.primary;
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentStatus &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

/// Función para convertir desde el formato del backend
AppointmentStatus statusFromString(String s) {
  switch (s) {
    case 'ASISTIDO':
      return AppointmentStatus.asistido;
    case 'NO_ASISTIDO':
      return AppointmentStatus.noAsistido;
    case 'PENDIENTE':
      return AppointmentStatus.pendiente;
  }
  return AppointmentStatus.pendiente;
}

/// Función para convertir al formato del backend
String statusToString(AppointmentStatus s) {
  switch (s.type) {
    case AppointmentStatusType.asistido:
      return 'ASISTIDO';
    case AppointmentStatusType.noAsistido:
      return 'NO_ASISTIDO';
    case AppointmentStatusType.pendiente:
      return 'PENDIENTE';
  }
}

/// Estados de ejercicios
enum EjercicioStatusType { pendiente, noRealizado }

class EjercicioStatus extends Status {
  final EjercicioStatusType type;
  
  EjercicioStatus._(this.type);
  
  static final pendiente = EjercicioStatus._(EjercicioStatusType.pendiente);
  static final noRealizado = EjercicioStatus._(EjercicioStatusType.noRealizado);
  
  @override
  String get label {
    switch (type) {
      case EjercicioStatusType.noRealizado:
        return 'No realizado';
      case EjercicioStatusType.pendiente:
        return 'Pendiente';
    }
  }
  
  @override
  Color color(BuildContext context) {
    switch (type) {
      case EjercicioStatusType.noRealizado:
        return Colors.redAccent;
      case EjercicioStatusType.pendiente:
        return Theme.of(context).colorScheme.primary;
    }
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EjercicioStatus &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}
