class Unidad {
  final int id;
  final String nombre;

  const Unidad({
    required this.id,
    required this.nombre,
  });

  factory Unidad.fromJson(Map<String, dynamic> json) => Unidad(
        id: json['id'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
      };
}
