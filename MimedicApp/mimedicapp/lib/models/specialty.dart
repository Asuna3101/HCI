class Specialty {
  final int id;
  final String nombre;
  Specialty({required this.id, required this.nombre});
  factory Specialty.fromJson(Map<String, dynamic> j) =>
      Specialty(id: j['id'], nombre: j['nombre']);
}
