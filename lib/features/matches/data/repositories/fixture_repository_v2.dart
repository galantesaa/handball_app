import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/context/app_context_key.dart';
import '../../../../core/storage/app_storage_keys.dart';
import '../../../settings/domain/models/active_context.dart';
import '../../../../models_v2.dart';
import '../../../../partido_repository_v2.dart';

class FixtureRepositoryV2 {
  const FixtureRepositoryV2();

  static String buildStableFixtureIdentity(PartidoModel partido) {
    return [
      PartidoRepositoryV2.normalizeValue(partido.temporada),
      PartidoRepositoryV2.normalizeValue(partido.competencia),
      PartidoRepositoryV2.normalizeValue(partido.torneo),
      PartidoRepositoryV2.normalizeValue(partido.categoria),
      PartidoRepositoryV2.normalizeValue(partido.rival),
      PartidoRepositoryV2.normalizeValue(partido.condicion),
    ].join('|');
  }

  static String buildStableFixtureIdentityFromMap(Map<String, dynamic> partido) {
    return [
      PartidoRepositoryV2.normalizeValue(partido['temporada'] ?? '2026'),
      PartidoRepositoryV2.normalizeValue(partido['competencia'] ?? 'Local'),
      PartidoRepositoryV2.normalizeValue(partido['torneo']),
      PartidoRepositoryV2.normalizeValue(partido['categoria']),
      PartidoRepositoryV2.normalizeValue(partido['rival']),
      PartidoRepositoryV2.normalizeValue(partido['condicion']),
    ].join('|');
  }

  Future<List<PartidoModel>> readFixtures() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.fixtures);

    if (raw == null || raw.trim().isEmpty || raw.trim() == 'null') {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        await prefs.remove(AppStorageKeys.fixtures);
        return const [];
      }

      final result = <PartidoModel>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        try {
          result.add(PartidoModel.fromMap(Map<String, dynamic>.from(item)));
        } catch (_) {
          continue;
        }
      }

      result.sort(_sortByFechaNumero);
      return result;
    } catch (_) {
      await prefs.remove(AppStorageKeys.fixtures);
      return const [];
    }
  }

  Future<List<PartidoModel>> readFixturesByContext(
    ActiveContext context,
  ) async {
    final fixtures = await readFixtures();

    final filtered = fixtures.where((partido) {
      return AppContextKey.matchesMap(
        data: partido.toMap(),
        context: context,
      );
    }).toList();

    filtered.sort(_sortByFechaNumero);
    return filtered;
  }

  Future<bool> saveFixture(PartidoModel partido) async {
    final prefs = await SharedPreferences.getInstance();
    final fixtures = await readFixtures();
    final normalized = _normalizePendingFixture(partido);

    final newIdentity = buildStableFixtureIdentity(normalized);

    final exists = fixtures.any((item) {
      return buildStableFixtureIdentity(item) == newIdentity;
    });

    if (exists) return false;

    final updated = <PartidoModel>[...fixtures, normalized]
      ..sort(_sortByFechaNumero);

    await prefs.setString(
      AppStorageKeys.fixtures,
      jsonEncode(updated.map((e) => e.toMap()).toList()),
    );

    return true;
  }

  Future<bool> updateFixture(PartidoModel partido) async {
    final prefs = await SharedPreferences.getInstance();
    final fixtures = await readFixtures();
    final normalized = _normalizePendingFixture(partido);

    final targetIdentity = buildStableFixtureIdentity(normalized);

    final index = fixtures.indexWhere((item) {
      return buildStableFixtureIdentity(item) == targetIdentity;
    });

    if (index < 0) return false;

    final updated = <PartidoModel>[...fixtures];
    updated[index] = normalized;
    updated.sort(_sortByFechaNumero);

    await prefs.setString(
      AppStorageKeys.fixtures,
      jsonEncode(updated.map((e) => e.toMap()).toList()),
    );

    return true;
  }

  Future<bool> replaceFixture({
    required PartidoModel oldPartido,
    required PartidoModel newPartido,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final fixtures = await readFixtures();

    final oldIdentity = buildStableFixtureIdentity(oldPartido);
    final normalizedNew = _normalizePendingFixture(newPartido);
    final newIdentity = buildStableFixtureIdentity(normalizedNew);

    final index = fixtures.indexWhere((item) {
      return buildStableFixtureIdentity(item) == oldIdentity;
    });

    if (index < 0) return false;

    final duplicatedIndex = fixtures.indexWhere((item) {
      return buildStableFixtureIdentity(item) == newIdentity;
    });

    if (duplicatedIndex >= 0 && duplicatedIndex != index) return false;

    final updated = <PartidoModel>[...fixtures];
    updated[index] = normalizedNew;
    updated.sort(_sortByFechaNumero);

    await prefs.setString(
      AppStorageKeys.fixtures,
      jsonEncode(updated.map((e) => e.toMap()).toList()),
    );

    return true;
  }

  Future<void> upsertFixture(PartidoModel partido) async {
    final saved = await saveFixture(partido);
    if (saved) return;

    await updateFixture(partido);
  }

  Future<bool> deleteFixture(PartidoModel partido) async {
    final prefs = await SharedPreferences.getInstance();
    final fixtures = await readFixtures();

    final targetIdentity = buildStableFixtureIdentity(partido);

    final updated = fixtures.where((item) {
      return buildStableFixtureIdentity(item) != targetIdentity;
    }).toList();

    if (updated.length == fixtures.length) return false;

    await prefs.setString(
      AppStorageKeys.fixtures,
      jsonEncode(updated.map((e) => e.toMap()).toList()),
    );

    return true;
  }

  Future<void> clearFixtures() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStorageKeys.fixtures);
  }

  PartidoModel _normalizePendingFixture(PartidoModel partido) {
    return partido.copyWith(
      estado: 'Pendiente',
      estadoPartido: 'no_iniciado',
      golesSanFernando: 0,
      golesRival: 0,
      golesRecibidos: 0,
      atajadas: 0,
      penales: 0,
      exclusiones2Min: 0,
      amarillas: 0,
      rojas: 0,
      perdidas: 0,
      recuperaciones: 0,
      penalesConvertidosSanFernando: 0,
      penalesConvertidosRival: 0,
      eventos: const [],
      archivedAt: null,
    );
  }

  int _sortByFechaNumero(PartidoModel a, PartidoModel b) {
    final byFecha = (a.fechaNumero ?? 999999).compareTo(
      b.fechaNumero ?? 999999,
    );

    if (byFecha != 0) return byFecha;

    return a.rival.toLowerCase().compareTo(b.rival.toLowerCase());
  }
}