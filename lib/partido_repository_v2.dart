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
    normalizeValue(partido.temporada),
    normalizeValue(partido.competencia),
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
    normalizeValue(partido['temporada'] ?? '2026'),
    normalizeValue(partido['competencia'] ?? 'Local'),
    normalizeValue(partido['torneo']),
    normalizeValue(partido['categoria']),
    normalizeValue(partido['fecha']),
    normalizeValue(partido['rival']),
    normalizeValue(partido['condicion']),
  ].join('|');
}
  /// ===============================
  /// READ LIVE MATCH SEGURO
  /// No rompe si live_match_current_v1 está null/corrupto.
  /// ===============================
  static Future<PartidoModel?> readLiveMatch() async {
    const liveMatchStorageKey = 'live_match_current_v1';

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(liveMatchStorageKey);

    if (raw == null || raw.trim().isEmpty || raw.trim() == 'null') {
      await prefs.remove(liveMatchStorageKey);
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded == null || decoded is! Map) {
        await prefs.remove(liveMatchStorageKey);
        return null;
      }

      final map = Map<String, dynamic>.from(decoded as Map);

      if (map.isEmpty) {
        await prefs.remove(liveMatchStorageKey);
        return null;
      }

      final partidoRaw = map['partido'];

      if (partidoRaw is Map) {
        final partidoMap = Map<String, dynamic>.from(partidoRaw);
        return PartidoModel.fromMap(partidoMap);
      }

      return PartidoModel.fromMap(map);
    } catch (_) {
      await prefs.remove(liveMatchStorageKey);
      return null;
    }
  }

  /// ===============================
  /// LEER PARTIDOS FINALIZADOS
  /// Devuelve la lista de partidos finalizados guardados.
  /// ===============================
    static Future<List<PartidoModel>> readFinishedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(finishedMatchesStorageKey);

    if (raw == null || raw.trim().isEmpty || raw.trim() == 'null') {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        await prefs.remove(finishedMatchesStorageKey);
        return const [];
      }

      final items = <PartidoModel>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        try {
          final data = Map<String, dynamic>.from(item);

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
            'archivedAt': data['archivedAt'] ?? partidoMap['archivedAt'],
          };

          items.add(PartidoModel.fromMap(merged));
        } catch (_) {
          continue;
        }
      }

      items.sort((a, b) {
        final aDate = DateTime.tryParse(a.archivedAt ?? '');
        final bDate = DateTime.tryParse(b.archivedAt ?? '');

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      return items;
    } catch (_) {
      await prefs.remove(finishedMatchesStorageKey);
      return const [];
    }
  }

}