class MedicamentoUsuario {
  final int? id;
  final String nombre;
  final double dosis;
  final String unidad;
  final double frecuenciaHoras;
  final DateTime fechaInicio;
  final DateTime fechaFin;

  MedicamentoUsuario({
    this.id,
    required this.nombre,
    required this.dosis,
    required this.unidad,
    required this.frecuenciaHoras,
    required this.fechaInicio,
    required this.fechaFin,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'unidad': unidad,
        'frecuencia_horas': frecuenciaHoras,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
      };

  factory MedicamentoUsuario.fromJson(Map<String, dynamic> json) {
    // Aceptar tanto snake_case como camelCase del backend
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) {
        // aceptar formatos ISO u otros; tryParse seguro
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final id = parseInt(json['id'] ?? json['ID']);
    final nombre = (json['nombre'] ?? json['name'] ?? '') as String;
    final dosis = parseDouble(json['dosis'] ?? json['dose']);
    final unidad = (json['unidad'] ?? json['unit'] ?? '') as String;
    final frecuenciaHoras = parseDouble(json['frecuencia_horas'] ?? json['frecuenciaHoras'] ?? json['frequency_hours']);
    final fechaInicio = parseDate(json['fecha_inicio'] ?? json['fechaInicio']);
    final fechaFin = parseDate(json['fecha_fin'] ?? json['fechaFin']);

    return MedicamentoUsuario(
      id: id,
      nombre: nombre,
      dosis: dosis,
      unidad: unidad,
      frecuenciaHoras: frecuenciaHoras,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }
}