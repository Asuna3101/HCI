import 'report_event.dart';

class ReportUser {
  final int? id;
  final String nombre;
  final String correo;
  final DateTime? fechaNacimiento;
  final DateTime? fechaCreacion;
  final String? foto;
  final String? fotoContentType;

  ReportUser({
    required this.id,
    required this.nombre,
    required this.correo,
    this.fechaNacimiento,
    this.fechaCreacion,
    this.foto,
    this.fotoContentType,
  });

  factory ReportUser.fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id'] as int?,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.tryParse(json['fecha_nacimiento'].toString())
          : null,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      foto: json['photo'] as String?,
      fotoContentType: json['photo_content_type'] as String?,
    );
  }
}

class ReportSummary {
  final ReportUser user;
  final List<ReportEventModel> timeline;

  ReportSummary({required this.user, required this.timeline});

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final timeline = (json['timeline'] as List? ?? [])
        .map((e) => ReportEventModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();
    return ReportSummary(
      user: ReportUser.fromJson(
          Map<String, dynamic>.from((json['user'] as Map? ?? {}))),
      timeline: timeline,
    );
  }
}
