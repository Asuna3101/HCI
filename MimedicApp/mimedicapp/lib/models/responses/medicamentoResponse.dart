class MedicamentoResponse {
  final int id;
  final String nombre;
  final String? message;

  MedicamentoResponse({
    required this.id,
    required this.nombre,
    this.message,
  });

  factory MedicamentoResponse.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String parseString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    return MedicamentoResponse(
      id: parseInt(json['id']),
      nombre: parseString(json['nombre']),
      message: json['message'] != null ? parseString(json['message']) : null,
    );
  }
}
