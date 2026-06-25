class HabitLog {
  final int id;
  final int habitId;
  final DateTime fecha;
  final bool completado;
  final int puntosObtenidos;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.fecha,
    required this.completado,
    required this.puntosObtenidos,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) => HabitLog(
        id: json['id'] as int,
        habitId: json['habito_id'] as int,
        fecha: DateTime.parse(json['fecha'] as String),
        completado: json['completado'] as bool? ?? true,
        puntosObtenidos: json['puntos_obtenidos'] as int? ?? 10,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'habit_id': habitId,
        'fecha': fecha.toIso8601String(),
        'completado': completado,
        'puntos_obtenidos': puntosObtenidos,
      };
}
