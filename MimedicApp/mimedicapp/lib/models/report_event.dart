enum ReportEventType { registro, medicacion, toma, cita, comida, ejercicio }

ReportEventType reportEventTypeFromString(String raw) {
  switch (raw.toLowerCase()) {
    case 'registro':
      return ReportEventType.registro;
    case 'medicacion':
      return ReportEventType.medicacion;
    case 'toma':
      return ReportEventType.toma;
    case 'cita':
      return ReportEventType.cita;
    case 'comida':
      return ReportEventType.comida;
    case 'ejercicio':
      return ReportEventType.ejercicio;
    default:
      return ReportEventType.registro;
  }
}

String reportEventTypeToString(ReportEventType type) {
  switch (type) {
    case ReportEventType.registro:
      return 'registro';
    case ReportEventType.medicacion:
      return 'medicacion';
    case ReportEventType.toma:
      return 'toma';
    case ReportEventType.cita:
      return 'cita';
    case ReportEventType.comida:
      return 'comida';
    case ReportEventType.ejercicio:
      return 'ejercicio';
  }
}

class ReportEventModel {
  final ReportEventType type;
  final String title;
  final String subtitle;
  final String? status;
  final DateTime date;

  ReportEventModel({
    required this.type,
    required this.title,
    required this.subtitle,
    this.status,
    required this.date,
  });

  factory ReportEventModel.fromJson(Map<String, dynamic> json) {
    return ReportEventModel(
      type: reportEventTypeFromString(json['type'] ?? ''),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      status: json['status'],
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
