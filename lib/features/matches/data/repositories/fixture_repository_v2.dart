import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/app_context_key.dart';
import '../../../../core/storage/app_storage_keys.dart';
import '../../../settings/domain/models/active_context.dart';
import '../models/models_v2.dart';
import '../models/partido_repository_v2.dart';

class FixtureRepositoryV2 {
  const FixtureRepositoryV2();

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
          final map = Map<String, dynamic>.from(item);
          result.add(PartidoModel.fromMap(map));
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

    return fixtures.where((partido) {
      final map = partido.toMap();

      return AppContextKey.matchesMap(
        data: map,
        context: context,
      );
    }).toList()
      ..sort(_sortByFechaNumero);
  }

  Future<bool> saveFixture(PartidoModel partido) async {
    final prefs = await SharedPreferences.getInstance();

    final fixtures = await readFixtures();

    final normalized = _normalizePendingFixture(partido);

    final newIdentity =
        PartidoRepositoryV2.buildMatchIdentityFromModel(normalized);

    final exists = fixtures.any((item) {
      final identity = PartidoRepositoryV2.buildMatchIdentityFromModel(item);
      return identity == newIdentity;
    });

    if (exists) return false;

    final updated = [...fixtures, normalized]..sort(_sortByFechaNumero);

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

    final targetIdentity =
        PartidoRepositoryV2.buildMatchIdentityFromModel(normalized);

    final index = fixtures.indexWhere((item) {
      final identity = PartidoRepositoryV2.buildMatchIdentityFromModel(item);
      return identity == targetIdentity;
    });

    if (index < 0) return false;

    final updated = [...fixtures];
    updated[index] = normalized;
    updated.sort(_sortByFechaNumero);

    await prefs.setString(
      AppStorageKeys.fixtures,
      jsonEncode(updated.map((e) => e.toMap()).toList()),
    );

    return true;
  }

  Future<bool> deleteFixture(PartidoModel partido) async {
    final prefs = await SharedPreferences.getInstance();

    final fixtures = await readFixtures();

    final targetIdentity =
        PartidoRepositoryV2.buildMatchIdentityFromModel(partido);

    final updated = fixtures.where((item) {
      final identity = PartidoRepositoryV2.buildMatchIdentityFromModel(item);
      return identity != targetIdentity;
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
    final aFecha = a.fechaNumero ?? 999999;
    final bFecha = b.fechaNumero ?? 999999;

    final byFecha = aFecha.compareTo(bFecha);
    if (byFecha != 0) return byFecha;

    return a.rival.toLowerCase().compareTo(b.rival.toLowerCase());
  }
}