class Ejercicio {
  final int id;
  final String nombre;

  Ejercicio({
    required this.id,
    required this.nombre,
  });
  
  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
