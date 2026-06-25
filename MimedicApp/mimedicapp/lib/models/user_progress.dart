class UserProgress {
  final int puntosTotal;
  final int rachaActual;
  final int rachaMayor;

  const UserProgress({
    required this.puntosTotal,
    required this.rachaActual,
    required this.rachaMayor,
  });

  static const empty =
      UserProgress(puntosTotal: 0, rachaActual: 0, rachaMayor: 0);

  int get nivel {
    if (puntosTotal >= 1000) return 5;
    if (puntosTotal >= 600) return 4;
    if (puntosTotal >= 300) return 3;
    if (puntosTotal >= 100) return 2;
    return 1;
  }

  String get nombreNivel {
    switch (nivel) {
      case 1:
        return 'Principiante';
      case 2:
        return 'Aprendiz';
      case 3:
        return 'Constante';
      case 4:
        return 'Dedicado';
      case 5:
        return 'Experto';
      default:
        return 'Principiante';
    }
  }

  int get _puntosNivelActual {
    switch (nivel) {
      case 1:
        return 0;
      case 2:
        return 100;
      case 3:
        return 300;
      case 4:
        return 600;
      case 5:
        return 1000;
      default:
        return 0;
    }
  }

  int get _puntosNivelSiguiente {
    switch (nivel) {
      case 1:
        return 100;
      case 2:
        return 300;
      case 3:
        return 600;
      case 4:
        return 1000;
      default:
        return 1000;
    }
  }

  double get progresoNivel {
    if (nivel == 5) return 1.0;
    final rango = _puntosNivelSiguiente - _puntosNivelActual;
    final actual = puntosTotal - _puntosNivelActual;
    return (actual / rango).clamp(0.0, 1.0);
  }

  int get puntosParaSiguienteNivel =>
      nivel == 5 ? 0 : _puntosNivelSiguiente - puntosTotal;

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        puntosTotal: json['puntos_total'] as int? ?? 0,
        rachaActual: json['racha_actual'] as int? ?? 0,
        rachaMayor: json['racha_mayor'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'puntos_total': puntosTotal,
        'racha_actual': rachaActual,
        'racha_mayor': rachaMayor,
      };

  UserProgress copyWith({int? puntosTotal, int? rachaActual, int? rachaMayor}) =>
      UserProgress(
        puntosTotal: puntosTotal ?? this.puntosTotal,
        rachaActual: rachaActual ?? this.rachaActual,
        rachaMayor: rachaMayor ?? this.rachaMayor,
      );
}
