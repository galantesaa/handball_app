class MatchModel {
  /// ================================
  /// BASICO
  /// ================================
  final String rival;
  final String fecha;
  final String hora;
  final String condicion;

  /// ================================
  /// CONTEXTO
  /// ================================
  final String categoria;
  final String torneo;

  /// ================================
  /// ESTADO
  /// ================================
  final bool finalizado;
  final int fechaNumero;

  /// ================================
  /// RESULTADO
  /// ================================
  final int golesLocal;
  final int golesRival;

  /// ================================
  /// ARQUERO
  /// ================================
  final int atajadas;
  final int golesRecibidos;

  /// ================================
  /// UI
  /// ================================
  final String? escudoRival;

  MatchModel({
    required this.rival,
    required this.fecha,
    required this.hora,
    required this.condicion,
    required this.categoria,
    required this.torneo,
    required this.finalizado,
    required this.fechaNumero,
    required this.golesLocal,
    required this.golesRival,
    required this.atajadas,
    required this.golesRecibidos,
    this.escudoRival,
  });

  /// ================================
  /// GETTERS UI
  /// ================================
  String get marcadorCancha => "$golesLocal - $golesRival";

  String get condicionVisible =>
      condicion.isEmpty ? '-' : condicion;

  /// ================================
  /// FACTORY DESDE MAP
  /// ================================
  factory MatchModel.fromMap(
  Map<String, dynamic> map, {
  bool? finalizadoOverride,
  String? escudoRivalOverride,
}) {
  final golesLocal = _toInt(map['golesLocal']);
  final golesRival = _toInt(map['golesRival']);

  return MatchModel(
    rival: (map['rival'] ?? '').toString(),
    fecha: (map['fecha'] ?? '').toString(),
    hora: (map['hora'] ?? '').toString(),
    condicion: (map['condicion'] ?? '').toString(),

    categoria: (map['categoria'] ?? '-').toString(),
    torneo: (map['torneo'] ?? '-').toString(),

    finalizado: finalizadoOverride ??
        (map['estado'] == 'finalizado'),

    fechaNumero: _toInt(map['fechaNumero']),

    golesLocal: golesLocal,
    golesRival: golesRival,

    atajadas: _toInt(map['atajadas']),
    golesRecibidos: golesRival,

    escudoRival: escudoRivalOverride ?? map['escudoRival'],
  );
}
  /// ================================
  /// SAFE INT
  /// ================================
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}