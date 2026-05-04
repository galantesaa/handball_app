/// ===============================
/// MATCH SQUAD MODEL
/// Representa el plantel convocado del partido:
/// - convocados
/// - arqueros seleccionados para ese partido
/// ===============================
class MatchSquadModel {
  final Set<String> convocadosIds;
  final Set<String> arquerosIds;

  const MatchSquadModel({
    required this.convocadosIds,
    required this.arquerosIds,
  });

  factory MatchSquadModel.empty() {
    return const MatchSquadModel(
      convocadosIds: <String>{},
      arquerosIds: <String>{},
    );
  }

  factory MatchSquadModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MatchSquadModel.empty();

    final convocadosRaw = (map['convocadosIds'] as List?) ?? const [];
    final arquerosRaw = (map['arquerosIds'] as List?) ?? const [];

    return MatchSquadModel(
      convocadosIds: convocadosRaw.map((e) => e.toString()).toSet(),
      arquerosIds: arquerosRaw.map((e) => e.toString()).toSet(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'convocadosIds': convocadosIds.toList(),
      'arquerosIds': arquerosIds.toList(),
    };
  }

  MatchSquadModel copyWith({
    Set<String>? convocadosIds,
    Set<String>? arquerosIds,
  }) {
    return MatchSquadModel(
      convocadosIds: convocadosIds ?? this.convocadosIds,
      arquerosIds: arquerosIds ?? this.arquerosIds,
    );
  }
}

/// ===============================
/// EVENTO MODEL
/// Representa un evento cargado durante el partido:
/// - tiro
/// - gol
/// - atajada
/// - pérdida
/// - sanción
/// etc.
/// ===============================
class EventoModel {
  final int id;
  final String timestamp;
  final String estadoPartido;
  final String? modo;
  final String? origenJugada;
  final String tipo;
  final String? resultado;
  final String? actorPrincipal;
  final String? actorPrincipalId;
  final String? actorSecundario;
  final String? zonaTiro;
  final String? zonaArco;
  final String? detalle;
  final String? subtipo;
  final String? arquero;
  final bool mantieneContexto;
  final Map<String, dynamic>? prevState;

  const EventoModel({
    required this.id,
    required this.timestamp,
    required this.estadoPartido,
    required this.tipo,
    required this.mantieneContexto,
    this.modo,
    this.origenJugada,
    this.resultado,
    this.actorPrincipal,
    this.actorPrincipalId,
    this.actorSecundario,
    this.zonaTiro,
    this.zonaArco,
    this.detalle,
    this.subtipo,
    this.arquero,
    this.prevState,
  });

  factory EventoModel.fromMap(Map<String, dynamic> map) {
    return EventoModel(
      id: (map['id'] as int?) ?? 0,
      timestamp: (map['timestamp'] ?? '').toString(),
      estadoPartido: (map['estadoPartido'] ?? '').toString(),
      modo: map['modo']?.toString(),
      origenJugada: map['origenJugada']?.toString(),
      tipo: (map['tipo'] ?? '').toString(),
      resultado: map['resultado']?.toString(),
      actorPrincipal: map['actorPrincipal']?.toString(),
      actorPrincipalId: map['actorPrincipalId']?.toString(),
      actorSecundario: map['actorSecundario']?.toString(),
      zonaTiro: map['zonaTiro']?.toString(),
      zonaArco: map['zonaArco']?.toString(),
      detalle: map['detalle']?.toString(),
      subtipo: map['subtipo']?.toString(),
      arquero: map['arquero']?.toString(),
      mantieneContexto: (map['mantieneContexto'] as bool?) ?? false,
      prevState: map['prevState'] is Map
          ? Map<String, dynamic>.from(map['prevState'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'estadoPartido': estadoPartido,
      'modo': modo,
      'origenJugada': origenJugada,
      'tipo': tipo,
      'resultado': resultado,
      'actorPrincipal': actorPrincipal,
      'actorPrincipalId': actorPrincipalId,
      'actorSecundario': actorSecundario,
      'zonaTiro': zonaTiro,
      'zonaArco': zonaArco,
      'detalle': detalle,
      'subtipo': subtipo,
      'arquero': arquero,
      'mantieneContexto': mantieneContexto,
      'prevState': prevState,
    };
  }
}

/// ===============================
/// PARTIDO MODEL
/// Representa un partido completo:
/// - datos generales
/// - estado
/// - estadísticas
/// - eventos
/// - plantel convocado
/// ===============================
class PartidoModel {
  final String rival;
  final int? fechaNumero;
  final String fecha;
  final String hora;
  final String condicion;
  final String torneo;
  final String categoria;

  final String estado;
  final String estadoPartido;

  final int golesSanFernando;
  final int golesRival;
  final int golesRecibidos;
  final int atajadas;
  final int penales;
  final int exclusiones2Min;
  final int amarillas;
  final int rojas;
  final int perdidas;
  final int recuperaciones;
  final int penalesConvertidosSanFernando;
  final int penalesConvertidosRival;

  final String? modoActual;
  final String? modoInicioPrimerTiempo;
  final String? modoInicioPrimerTiempoAlargue;
  final String? currentGoalkeeperNumber;
  final String? escudoRival;
  final String? archivedAt;

  final List<EventoModel> eventos;
  final MatchSquadModel? matchSquad;

  const PartidoModel({
    required this.rival,
    required this.fecha,
    required this.hora,
    required this.condicion,
    required this.torneo,
    required this.categoria,
    required this.estado,
    required this.estadoPartido,
    required this.golesSanFernando,
    required this.golesRival,
    required this.golesRecibidos,
    required this.atajadas,
    required this.penales,
    required this.exclusiones2Min,
    required this.amarillas,
    required this.rojas,
    required this.perdidas,
    required this.recuperaciones,
    required this.penalesConvertidosSanFernando,
    required this.penalesConvertidosRival,
    required this.eventos,
    this.fechaNumero,
    this.modoActual,
    this.modoInicioPrimerTiempo,
    this.modoInicioPrimerTiempoAlargue,
    this.currentGoalkeeperNumber,
    this.escudoRival,
    this.archivedAt,
    this.matchSquad,
  });

  factory PartidoModel.fromMap(Map<String, dynamic> map) {
    final eventosRaw = (map['eventos'] as List?) ?? const [];

    return PartidoModel(
      rival: (map['rival'] ?? 'Rival').toString(),
      fechaNumero: map['fechaNumero'] as int?,
      fecha: (map['fecha'] ?? '').toString(),
      hora: (map['hora'] ?? '').toString(),
      condicion: (map['condicion'] ?? 'Local').toString(),
      torneo: (map['torneo'] ?? '').toString(),
      categoria: (map['categoria'] ?? '').toString(),
      estado: (map['estado'] ?? 'Pendiente').toString(),
      estadoPartido: (map['estadoPartido'] ?? 'no_iniciado').toString(),
      golesSanFernando: (map['golesSanFernando'] as int?) ?? 0,
      golesRival: (map['golesRival'] as int?) ?? 0,
      golesRecibidos: (map['golesRecibidos'] as int?) ?? 0,
      atajadas: (map['atajadas'] as int?) ?? 0,
      penales: (map['penales'] as int?) ?? 0,
      exclusiones2Min: (map['exclusiones2Min'] as int?) ?? 0,
      amarillas: (map['amarillas'] as int?) ?? 0,
      rojas: (map['rojas'] as int?) ?? 0,
      perdidas: (map['perdidas'] as int?) ?? 0,
      recuperaciones: (map['recuperaciones'] as int?) ?? 0,
      penalesConvertidosSanFernando:
          (map['penalesConvertidosSanFernando'] as int?) ?? 0,
      penalesConvertidosRival: (map['penalesConvertidosRival'] as int?) ?? 0,
      modoActual: map['modoActual']?.toString(),
      modoInicioPrimerTiempo: map['modoInicioPrimerTiempo']?.toString(),
      modoInicioPrimerTiempoAlargue: map['modoInicioPrimerTiempoAlargue']
          ?.toString(),
      currentGoalkeeperNumber: map['currentGoalkeeperNumber']?.toString(),
      escudoRival: map['escudoRival']?.toString(),
      archivedAt: map['archivedAt']?.toString(),
      eventos: eventosRaw
          .map((e) => EventoModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      matchSquad: map['matchSquad'] is Map
          ? MatchSquadModel.fromMap(
              Map<String, dynamic>.from(map['matchSquad'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rival': rival,
      'fechaNumero': fechaNumero,
      'fecha': fecha,
      'hora': hora,
      'condicion': condicion,
      'torneo': torneo,
      'categoria': categoria,
      'estado': estado,
      'estadoPartido': estadoPartido,
      'golesSanFernando': golesSanFernando,
      'golesRival': golesRival,
      'golesRecibidos': golesRecibidos,
      'atajadas': atajadas,
      'penales': penales,
      'exclusiones2Min': exclusiones2Min,
      'amarillas': amarillas,
      'rojas': rojas,
      'perdidas': perdidas,
      'recuperaciones': recuperaciones,
      'penalesConvertidosSanFernando': penalesConvertidosSanFernando,
      'penalesConvertidosRival': penalesConvertidosRival,
      'modoActual': modoActual,
      'modoInicioPrimerTiempo': modoInicioPrimerTiempo,
      'modoInicioPrimerTiempoAlargue': modoInicioPrimerTiempoAlargue,
      'currentGoalkeeperNumber': currentGoalkeeperNumber,
      'escudoRival': escudoRival,
      'archivedAt': archivedAt,
      'eventos': eventos.map((e) => e.toMap()).toList(),
      'matchSquad': matchSquad?.toMap(),
    };
  }

  PartidoModel copyWith({
    String? rival,
    int? fechaNumero,
    String? fecha,
    String? hora,
    String? condicion,
    String? torneo,
    String? categoria,
    String? estado,
    String? estadoPartido,
    int? golesSanFernando,
    int? golesRival,
    int? golesRecibidos,
    int? atajadas,
    int? penales,
    int? exclusiones2Min,
    int? amarillas,
    int? rojas,
    int? perdidas,
    int? recuperaciones,
    int? penalesConvertidosSanFernando,
    int? penalesConvertidosRival,
    String? modoActual,
    String? modoInicioPrimerTiempo,
    String? modoInicioPrimerTiempoAlargue,
    String? currentGoalkeeperNumber,
    String? escudoRival,
    String? archivedAt,
    List<EventoModel>? eventos,
    MatchSquadModel? matchSquad,
  }) {
    return PartidoModel(
      rival: rival ?? this.rival,
      fechaNumero: fechaNumero ?? this.fechaNumero,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      condicion: condicion ?? this.condicion,
      torneo: torneo ?? this.torneo,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      estadoPartido: estadoPartido ?? this.estadoPartido,
      golesSanFernando: golesSanFernando ?? this.golesSanFernando,
      golesRival: golesRival ?? this.golesRival,
      golesRecibidos: golesRecibidos ?? this.golesRecibidos,
      atajadas: atajadas ?? this.atajadas,
      penales: penales ?? this.penales,
      exclusiones2Min: exclusiones2Min ?? this.exclusiones2Min,
      amarillas: amarillas ?? this.amarillas,
      rojas: rojas ?? this.rojas,
      perdidas: perdidas ?? this.perdidas,
      recuperaciones: recuperaciones ?? this.recuperaciones,
      penalesConvertidosSanFernando:
          penalesConvertidosSanFernando ?? this.penalesConvertidosSanFernando,
      penalesConvertidosRival:
          penalesConvertidosRival ?? this.penalesConvertidosRival,
      modoActual: modoActual ?? this.modoActual,
      modoInicioPrimerTiempo:
          modoInicioPrimerTiempo ?? this.modoInicioPrimerTiempo,
      modoInicioPrimerTiempoAlargue:
          modoInicioPrimerTiempoAlargue ?? this.modoInicioPrimerTiempoAlargue,
      currentGoalkeeperNumber:
          currentGoalkeeperNumber ?? this.currentGoalkeeperNumber,
      escudoRival: escudoRival ?? this.escudoRival,
      archivedAt: archivedAt ?? this.archivedAt,
      eventos: eventos ?? this.eventos,
      matchSquad: matchSquad ?? this.matchSquad,
    );
  }

  bool get estaFinalizado => estadoPartido == 'finalizado';

  double get eficaciaArquero {
    final total = atajadas + golesRecibidos;
    if (total == 0) return 0;
    return (atajadas / total) * 100;
  }
}
