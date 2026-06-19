class Toma {
  final int id;
  final int idMedxUser;
  final bool tomado;
  final DateTime adquired;
  final String medicamentoNombre;
  final double dosis;
  final String unidad;

  Toma({
    required this.id,
    required this.idMedxUser,
    required this.tomado,
    required this.adquired,
    required this.medicamentoNombre,
    required this.dosis,
    required this.unidad,
  });

  factory Toma.fromJson(Map<String, dynamic> json) {
    return Toma(
      id: json['id'] as int,
      idMedxUser: json['idMedxUser'] as int,
      tomado: json['tomado'] as bool,
      adquired: DateTime.parse(json['adquired'] as String).toUtc(),
      medicamentoNombre: (json['medicamentoNombre'] ?? '') as String,
      dosis: (json['dosis'] is int) ? (json['dosis'] as int).toDouble() : (json['dosis'] ?? 0.0) as double,
      unidad: (json['unidad'] ?? '') as String,
    );
  }
}
