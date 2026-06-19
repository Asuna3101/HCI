class Medicamento {
  final int id;
  final String nombre;

  Medicamento({
    required this.id,
    required this.nombre,
  });

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
