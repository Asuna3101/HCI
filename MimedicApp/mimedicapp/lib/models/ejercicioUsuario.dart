class EjercicioUsuario {
  final int? id;
  final String? nombre;
  final String? notas;
  final String? horario;
  final int? duracionMin;
  final bool? realizado;
  bool notificado;

  EjercicioUsuario({
    this.id,
    this.nombre,
    this.notas,
    this.horario,
    this.duracionMin,
    this.realizado,
    this.notificado = false
  });

  factory EjercicioUsuario.fromJson(Map<String, dynamic> json) {
    return EjercicioUsuario(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      notas: json['notas'] as String?,
      horario: json['horario'] as String?,  
      duracionMin: json['duracion_min'] as int?,
      realizado: json['realizado'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (notas != null) 'notas': notas,
      if (horario != null) 'horario': horario,
      if (duracionMin != null) 'duracion_min': duracionMin,
      if (realizado != null) 'realizado': realizado,
    };
  }
}