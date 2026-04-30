class MatchModel {
  final String rival;
  final String fecha;
  final String hora;
  final String condicion;
  final String categoria;
  final String torneo;
  final bool finalizado;
  final int fechaNumero;

  /// Resultado normalizado por cancha.
  /// Ejemplo visitante:
  /// equipoLocal = Rival, equipoVisitante = San Fernando.
  final int golesLocal;
  final int golesVisitante;

  /// Resultado desde la mirada de San Fernando.
  final int golesSanFernando;
  final int golesRival;
  final int golesFavor;
  final int golesContra;

  final int atajadas;
  final int golesRecibidos;
  final String? escudoRival;
  final String equipoPropio;
  final String equipoLocal;
  final String equipoVisitante;
  final String? escudoLocal;
  final String? escudoVisitante;

  const MatchModel({
    required this.rival,
    required this.fecha,
    required this.hora,
    required this.condicion,
    required this.categoria,
    required this.torneo,
    required this.finalizado,
    required this.fechaNumero,
    required this.golesLocal,
    required this.golesVisitante,
    required this.golesSanFernando,
    required this.golesRival,
    required this.golesFavor,
    required this.golesContra,
    required this.atajadas,
    required this.golesRecibidos,
    required this.equipoPropio,
    required this.equipoLocal,
    required this.equipoVisitante,
    this.escudoRival,
    this.escudoLocal,
    this.escudoVisitante,
  });

  bool get somosLocales => condicion.toLowerCase().trim() == 'local';

  String get marcadorCancha => '$golesLocal - $golesVisitante';

  String get marcadorPropio => '$golesFavor - $golesContra';

  String get condicionVisible => _visible(condicion);

  String get resultadoEstado {
    if (!finalizado) return 'Pendiente';
    if (golesFavor > golesContra) return 'Ganado';
    if (golesFavor < golesContra) return 'Perdido';
    return 'Empatado';
  }

  factory MatchModel.fromMap(
    Map<String, dynamic> raw, {
    bool? finalizadoOverride,
    String? escudoRivalOverride,
  }) {
    final map = _unwrapPartido(raw);

    final condicion = _text(map['condicion'], fallback: '-');
    final somosLocales = condicion.toLowerCase().trim() == 'local';

    final golesSF = _firstInt(map, const [
      'golesSanFernando',
      'golesFavor',
    ]);

    final golesDelRival = _firstInt(map, const [
      'golesRival',
      'golesContra',
    ]);

    /// Prioridad correcta:
    /// 1) JSON nuevo: golesLocal / golesVisitante.
    /// 2) JSON viejo: calcular por condicion + golesSanFernando/golesRival.
    final golesLocal = _hasUsable(map, 'golesLocal')
        ? _toInt(map['golesLocal'])
        : (somosLocales ? golesSF : golesDelRival);

    final golesVisitante = _hasUsable(map, 'golesVisitante')
        ? _toInt(map['golesVisitante'])
        : (somosLocales ? golesDelRival : golesSF);

    final estado = _text(map['estado'], fallback: '').toLowerCase();
    final estadoPartido = _text(map['estadoPartido'], fallback: '').toLowerCase();

    return MatchModel(
      rival: _text(map['rival'], fallback: 'Rival'),
      fecha: _text(map['fecha'], fallback: '-'),
      hora: _text(map['hora'], fallback: '-'),
      condicion: condicion,
      categoria: _text(map['categoria'], fallback: '-'),
      torneo: _text(map['torneo'], fallback: '-'),
      finalizado: finalizadoOverride ??
          map['finalizado'] == true ||
          estado == 'finalizado' ||
          estadoPartido == 'finalizado',
      fechaNumero: _toInt(map['fechaNumero']),
      golesLocal: golesLocal,
      golesVisitante: golesVisitante,
      golesSanFernando: golesSF,
      golesRival: golesDelRival,
      golesFavor: _hasUsable(map, 'golesFavor') ? _toInt(map['golesFavor']) : golesSF,
      golesContra: _hasUsable(map, 'golesContra') ? _toInt(map['golesContra']) : golesDelRival,
      atajadas: _toInt(map['atajadas']),
      golesRecibidos: _hasUsable(map, 'golesRecibidos')
          ? _toInt(map['golesRecibidos'])
          : golesDelRival,
      escudoRival: escudoRivalOverride ?? _nullableText(map['escudoRival']),
      equipoPropio: _text(map['equipoPropio'], fallback: 'San Fernando Handball'),
      equipoLocal: _text(
        map['equipoLocal'],
        fallback: somosLocales ? 'San Fernando Handball' : _text(map['rival'], fallback: 'Rival'),
      ),
      equipoVisitante: _text(
        map['equipoVisitante'],
        fallback: somosLocales ? _text(map['rival'], fallback: 'Rival') : 'San Fernando Handball',
      ),
      escudoLocal: _nullableText(map['escudoLocal']),
      escudoVisitante: _nullableText(map['escudoVisitante']),
    );
  }

  static Map<String, dynamic> _unwrapPartido(Map<String, dynamic> raw) {
    final nested = raw['partido'];
    if (nested is Map) {
      final base = Map<String, dynamic>.from(nested);
      raw.forEach((key, value) {
        if (key != 'partido' && value != null) base.putIfAbsent(key, () => value);
      });
      return base;
    }
    return raw;
  }

  static bool _hasUsable(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty && value.trim().toLowerCase() != 'null';
    return true;
  }

  static int _firstInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (_hasUsable(map, key)) return _toInt(map[key]);
    }
    return 0;
  }

  static String _visible(String value) {
    final text = value.trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '-';
    return text;
  }

  static String _text(dynamic value, {required String fallback}) {
    final text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return text;
  }

  static String? _nullableText(dynamic value) {
    final text = (value ?? '').toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }
}
