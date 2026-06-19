class Clinic {
  final int id;
  final String nombre;
  Clinic({required this.id, required this.nombre});
  factory Clinic.fromJson(Map<String, dynamic> j) =>
      Clinic(id: j['id'], nombre: j['nombre']);
}
