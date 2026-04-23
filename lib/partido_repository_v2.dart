import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models_v2.dart';

/// ===============================
/// PARTIDO REPOSITORY V2
/// Centraliza lectura básica de:
/// - partido en vivo
/// - partidos finalizados
/// - identidad única del partido
/// ===============================
class PartidoRepositoryV2 {
  static const String liveMatchStorageKey = 'live_match_current_v1';
  static const String finishedMatchesStorageKey = 'finished_matches_history_v1';

  /// ===============================
  /// NORMALIZAR VALOR
  /// Sirve para construir identidades consistentes
  /// sin depender de mayúsculas o acentos.
  /// ===============================
  static String normalizeValue(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  /// ===============================
  /// MATCH IDENTITY
  /// Construye la identidad única de un partido.
  /// ===============================
  static String buildMatchIdentityFromModel(PartidoModel partido) {
    return [
      normalizeValue(partido.torneo),
      normalizeValue(partido.categoria),
      normalizeValue(partido.fecha),
      normalizeValue(partido.rival),
      normalizeValue(partido.condicion),
    ].join('|');
  }

  /// ===============================
  /// MATCH IDENTITY DESDE MAP
  /// Compatible con la estructura actual de la app.
  /// ===============================
  static String buildMatchIdentityFromMap(Map<String, dynamic> partido) {
    return [
      normalizeValue(partido['torneo']),
      normalizeValue(partido['categoria']),
      normalizeValue(partido['fecha']),
      normalizeValue(partido['rival']),
      normalizeValue(partido['condicion']),
    ].join('|');
  }

  /// ===============================
  /// LEER PARTIDO EN VIVO
  /// Devuelve el partido en vivo actual si existe.
  /// ===============================
  static Future<PartidoModel?> readLiveMatch() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(liveMatchStorageKey);

    if (raw == null || raw.isEmpty) return null;

    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);

    final partidoMap = Map<String, dynamic>.from(
      (data['partido'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );

    final merged = {
      ...partidoMap,
      'estadoPartido': data['estadoPartido'] ?? partidoMap['estadoPartido'],
      'golesSanFernando':
          data['golesSanFernando'] ?? partidoMap['golesSanFernando'],
      'golesRival': data['golesRival'] ?? partidoMap['golesRival'],
      'golesRecibidos': data['golesRecibidos'] ?? partidoMap['golesRecibidos'],
      'atajadas': data['atajadas'] ?? partidoMap['atajadas'],
      'penales': data['penales'] ?? partidoMap['penales'],
      'exclusiones2Min':
          data['exclusiones2Min'] ?? partidoMap['exclusiones2Min'],
      'amarillas': data['amarillas'] ?? partidoMap['amarillas'],
      'rojas': data['rojas'] ?? partidoMap['rojas'],
      'perdidas': data['perdidas'] ?? partidoMap['perdidas'],
      'recuperaciones': data['recuperaciones'] ?? partidoMap['recuperaciones'],
      'penalesConvertidosSanFernando':
          data['penalesConvertidosSanFernando'] ??
          partidoMap['penalesConvertidosSanFernando'],
      'penalesConvertidosRival':
          data['penalesConvertidosRival'] ??
          partidoMap['penalesConvertidosRival'],
      'modoActual': data['modo'] ?? partidoMap['modoActual'],
      'modoInicioPrimerTiempo':
          data['modoInicioPrimerTiempo'] ??
          partidoMap['modoInicioPrimerTiempo'],
      'modoInicioPrimerTiempoAlargue':
          data['modoInicioPrimerTiempoAlargue'] ??
          partidoMap['modoInicioPrimerTiempoAlargue'],
      'currentGoalkeeperNumber':
          data['currentGoalkeeperNumber'] ??
          partidoMap['currentGoalkeeperNumber'],
      'eventos': data['eventos'] ?? partidoMap['eventos'] ?? <dynamic>[],
    };

    return PartidoModel.fromMap(merged);
  }

  /// ===============================
  /// LEER PARTIDOS FINALIZADOS
  /// Devuelve la lista de partidos finalizados guardados.
  /// ===============================
  static Future<List<PartidoModel>> readFinishedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(finishedMatchesStorageKey);

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;

    final items = decoded.map((e) {
      final data = Map<String, dynamic>.from(e as Map);

      final partidoMap = Map<String, dynamic>.from(
        (data['partido'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      );

      final merged = {
        ...partidoMap,
        'estado': 'Finalizado',
        'estadoPartido': 'finalizado',
        'golesSanFernando':
            data['golesSanFernando'] ?? partidoMap['golesSanFernando'],
        'golesRival': data['golesRival'] ?? partidoMap['golesRival'],
        'golesRecibidos':
            data['golesRecibidos'] ?? partidoMap['golesRecibidos'],
        'atajadas': data['atajadas'] ?? partidoMap['atajadas'],
        'penales': data['penales'] ?? partidoMap['penales'],
        'exclusiones2Min':
            data['exclusiones2Min'] ?? partidoMap['exclusiones2Min'],
        'amarillas': data['amarillas'] ?? partidoMap['amarillas'],
        'rojas': data['rojas'] ?? partidoMap['rojas'],
        'perdidas': data['perdidas'] ?? partidoMap['perdidas'],
        'recuperaciones':
            data['recuperaciones'] ?? partidoMap['recuperaciones'],
        'penalesConvertidosSanFernando':
            data['penalesConvertidosSanFernando'] ??
            partidoMap['penalesConvertidosSanFernando'],
        'penalesConvertidosRival':
            data['penalesConvertidosRival'] ??
            partidoMap['penalesConvertidosRival'],
        'eventos': data['eventos'] ?? partidoMap['eventos'] ?? <dynamic>[],
        'archivedAt': data['archivedAt'],
      };

      return PartidoModel.fromMap(merged);
    }).toList();

    items.sort((a, b) {
      final aDate = DateTime.tryParse(a.archivedAt ?? '');
      final bDate = DateTime.tryParse(b.archivedAt ?? '');

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return items;
  }
}
