import 'package:flutter/material.dart';

class Habit {
  final int id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int puntosPorCompletar;
  final bool activo;

  const Habit({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.puntosPorCompletar,
    this.activo = true,
  });

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String,
        icono: json['icono'] as String? ?? 'star',
        puntosPorCompletar: json['puntos_por_completar'] as int? ?? 10,
        activo: json['activo'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'icono': icono,
        'puntos_por_completar': puntosPorCompletar,
        'activo': activo,
      };

  IconData get iconData {
    switch (icono) {
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color get color {
    switch (id) {
      case 1:
        return const Color(0xFF42A5F5); // azul agua
      case 2:
        return const Color(0xFF7E57C2); // morado sueño
      case 3:
        return const Color(0xFFEF5350); // rojo ejercicio
      case 4:
        return const Color(0xFF26A69A); // verde lectura
      case 5:
        return const Color(0xFFEC407A); // rosa meditación
      default:
        return const Color(0xFF3A1855);
    }
  }

  static List<Habit> get predefinidos => [
        const Habit(
          id: 1,
          nombre: 'Agua',
          descripcion: 'Toma 8 vasos de agua',
          icono: 'water_drop',
          puntosPorCompletar: 10,
        ),
        const Habit(
          id: 2,
          nombre: 'Sueño',
          descripcion: 'Duerme 8 horas',
          icono: 'bedtime',
          puntosPorCompletar: 10,
        ),
        const Habit(
          id: 3,
          nombre: 'Ejercicio',
          descripcion: '30 min de actividad física',
          icono: 'fitness_center',
          puntosPorCompletar: 10,
        ),
        const Habit(
          id: 4,
          nombre: 'Lectura',
          descripcion: 'Lee 30 minutos',
          icono: 'menu_book',
          puntosPorCompletar: 10,
        ),
        const Habit(
          id: 5,
          nombre: 'Meditación',
          descripcion: 'Medita 10 minutos',
          icono: 'self_improvement',
          puntosPorCompletar: 10,
        ),
      ];
}
