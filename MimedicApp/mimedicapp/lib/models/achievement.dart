import 'package:flutter/material.dart';

class Achievement {
  final int id;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final String criterio;
  final bool desbloqueado;
  final DateTime? desbloquedoEn;

  const Achievement({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.criterio,
    this.desbloqueado = false,
    this.desbloquedoEn,
  });

  Achievement copyWith({bool? desbloqueado, DateTime? desbloquedoEn}) =>
      Achievement(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        icono: icono,
        criterio: criterio,
        desbloqueado: desbloqueado ?? this.desbloqueado,
        desbloquedoEn: desbloquedoEn ?? this.desbloquedoEn,
      );

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        descripcion: json['descripcion'] as String,
        icono: Icons.emoji_events_rounded,
        criterio: json['criterio'] as String? ?? '',
        desbloqueado: json['desbloqueado'] as bool? ?? false,
        desbloquedoEn: json['desbloqueado_en'] != null
            ? DateTime.parse(json['desbloqueado_en'] as String)
            : null,
      );

  static List<Achievement> get todos => const [
        Achievement(
          id: 1,
          nombre: '¡Primer Paso!',
          descripcion: 'Completa tu primer hábito del día',
          icono: Icons.flag_rounded,
          criterio: 'completar_1_habito',
        ),
        Achievement(
          id: 2,
          nombre: 'Día Perfecto',
          descripcion: 'Completa todos los hábitos en un mismo día',
          icono: Icons.star_rounded,
          criterio: 'todos_habitos_dia',
        ),
        Achievement(
          id: 3,
          nombre: 'Racha de 3',
          descripcion: 'Mantén una racha de 3 días consecutivos',
          icono: Icons.local_fire_department_rounded,
          criterio: 'racha_3',
        ),
        Achievement(
          id: 4,
          nombre: 'Semana Activa',
          descripcion: 'Completa al menos un hábito por 7 días seguidos',
          icono: Icons.calendar_month_rounded,
          criterio: 'racha_7',
        ),
        Achievement(
          id: 5,
          nombre: 'Experto en Hábitos',
          descripcion: 'Alcanza el nivel Experto (1000 puntos)',
          icono: Icons.military_tech_rounded,
          criterio: 'nivel_5',
        ),
      ];
}
