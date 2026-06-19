class Doctor {
  final int id;
  final String nombre;
  Doctor({required this.id, required this.nombre});
  factory Doctor.fromJson(Map<String, dynamic> j) =>
      Doctor(id: j['id'], nombre: j['nombre']);
}
