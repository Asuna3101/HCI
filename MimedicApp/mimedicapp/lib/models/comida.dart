class Comida {
  final int? id;
  final String nombre;
  final String? detalles;
  final String? descripcion; // Descripción personalizada del usuario
  final int? categoriaId;
  final String? categoriaNombre;
  final String? createdAt;

  Comida({
    this.id,
    required this.nombre,
    this.detalles,
    this.descripcion,
    this.categoriaId,
    this.categoriaNombre,
    this.createdAt,
  });

  factory Comida.fromJson(Map<String, dynamic> json) {
    return Comida(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      detalles: json['detalles'] as String?,
      descripcion: json['descripcion'] as String?,
      categoriaId: json['categoria_id'] as int?,
      categoriaNombre: json['categoria_nombre'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'detalles': detalles,
        'descripcion': descripcion,
        'idCategoria': categoriaId,
      };

  bool get esRecomendable => categoriaId == 1;
}
