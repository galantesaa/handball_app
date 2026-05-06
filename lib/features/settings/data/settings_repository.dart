import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';
import '../domain/models/active_context.dart';

class SettingsRepository {
  Future<void> saveActiveContext(ActiveContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      AppStorageKeys.activeContext,
      jsonEncode(context.toJson()),
    );
  }

  Future<ActiveContext> getActiveContext() async {
  final prefs = await SharedPreferences.getInstance();

  final raw = prefs.getString(AppStorageKeys.activeContext);

  if (raw == null || raw.trim().isEmpty) {
    return ActiveContext.empty();
  }

  try {
    final decoded = jsonDecode(raw);

    if (decoded is! Map) {
      return ActiveContext.empty();
    }

    final map = Map<String, dynamic>.from(decoded);

    final context = ActiveContext.fromJson(map);

    // Compatibilidad migración vieja.
    if (context.tournament.trim().isEmpty &&
        context.competition.trim().isNotEmpty) {
      final migrated = context.copyWith(
        tournament: context.competition,
        competition: 'Local',
      );

      await saveActiveContext(migrated);

      return migrated;
    }

    return context;
  } catch (_) {
    return ActiveContext.empty();
  }
}
  
  Future<void> clearActiveContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStorageKeys.activeContext);
  }

  Future<void> seedDevelopmentContext() async {
  final initial = ActiveContext.initialSeed();
  await saveActiveContext(initial);
}

}

class CompetitionConfig {
  final String name;
  final String type;
  final List<String> tournaments;

  const CompetitionConfig({
    required this.name,
    required this.type,
    required this.tournaments,
  });

  bool get isLocal => type == 'local';

  bool get isSingleTournament => type == 'single';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'tournaments': tournaments,
    };
  }

  factory CompetitionConfig.fromJson(Map<String, dynamic> json) {
    final rawTournaments = json['tournaments'];

    return CompetitionConfig(
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'single').toString(),
      tournaments: rawTournaments is List
          ? rawTournaments.map((e) => e.toString()).toList()
          : const ['Único'],
    );
  }
}

class StructureRepository {
  Future<List<String>> getSeasons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.seasons);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSeasons(List<String> seasons) async {
    final prefs = await SharedPreferences.getInstance();

    final clean = seasons
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    await prefs.setString(AppStorageKeys.seasons, jsonEncode(clean));
  }

  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.categories);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();

    final clean = categories
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    await prefs.setString(AppStorageKeys.categories, jsonEncode(clean));
  }

  Future<List<CompetitionConfig>> getCompetitions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.competitions);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map((e) => CompetitionConfig.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.name.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCompetitions(List<CompetitionConfig> competitions) async {
    final prefs = await SharedPreferences.getInstance();

    final clean = competitions
        .where((e) => e.name.trim().isNotEmpty)
        .map((e) => e.toJson())
        .toList();

    await prefs.setString(AppStorageKeys.competitions, jsonEncode(clean));
  }

  Future<void> ensureInitialStructureFromActiveContext({
    required String season,
    required String competition,
    required String tournament,
    required String category,
  }) async {
    final seasons = await getSeasons();
    if (season.trim().isNotEmpty && !seasons.contains(season)) {
      await saveSeasons([...seasons, season]);
    }

    final categories = await getCategories();
    if (category.trim().isNotEmpty && !categories.contains(category)) {
      await saveCategories([...categories, category]);
    }

    final competitions = await getCompetitions();
    final exists = competitions.any((c) => c.name == competition);

    if (!exists && competition.trim().isNotEmpty) {
      await saveCompetitions([
        ...competitions,
        CompetitionConfig(
          name: competition,
          type: competition == 'Local' ? 'local' : 'single',
          tournaments: competition == 'Local'
              ? const ['Apertura', 'Clausura']
              : [tournament.trim().isEmpty ? 'Único' : tournament],
        ),
      ]);
    }
  }
}