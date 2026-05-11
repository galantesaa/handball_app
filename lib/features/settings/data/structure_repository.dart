import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';

class CompetitionStageConfig {
  final String id;
  final String name;
  final int order;
  final bool hasFixture;
  final bool allowManualMatches;
  final bool allowKnockoutRounds;
  final String stageType;

  const CompetitionStageConfig({
    required this.id,
    required this.name,
    required this.order,
    required this.hasFixture,
    required this.allowManualMatches,
    required this.allowKnockoutRounds,
    required this.stageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'hasFixture': hasFixture,
      'allowManualMatches': allowManualMatches,
      'allowKnockoutRounds': allowKnockoutRounds,
      'stageType': stageType,
    };
  }

  factory CompetitionStageConfig.fromJson(Map<String, dynamic> json) {
    return CompetitionStageConfig(
      id: (json['id'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      order: json['order'] is int ? json['order'] as int : 0,
      hasFixture: json['hasFixture'] == true,
      allowManualMatches: json['allowManualMatches'] != false,
      allowKnockoutRounds: json['allowKnockoutRounds'] == true,
      stageType: (json['stageType'] ?? 'league').toString().trim(),
    );
  }
}

class CompetitionConfig {
  final String name;

  /// Compatibilidad legacy:
  /// - local
  /// - single
  final String type;

  /// Compatibilidad legacy:
  /// antes representaba Apertura/Clausura/Único.
  final List<String> tournaments;

  /// Nuevo modelo configurable:
  /// - loose_matches
  /// - single_fixture
  /// - split_fixture
  /// - phased_fixture
  final String mode;

  final bool hasFixture;
  final bool allowManualMatches;
  final bool allowKnockoutRounds;
  final List<CompetitionStageConfig> stages;

  const CompetitionConfig({
    required this.name,
    required this.type,
    required this.tournaments,
    required this.mode,
    required this.hasFixture,
    required this.allowManualMatches,
    required this.allowKnockoutRounds,
    required this.stages,
  });

  bool get isLocal => type == 'local';

  bool get isSingleTournament => type == 'single';

  bool get isLooseMatches => mode == 'loose_matches';

  bool get isSingleFixture => mode == 'single_fixture';

  bool get isSplitFixture => mode == 'split_fixture';

  bool get isPhasedFixture => mode == 'phased_fixture';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'tournaments': tournaments,
      'mode': mode,
      'hasFixture': hasFixture,
      'allowManualMatches': allowManualMatches,
      'allowKnockoutRounds': allowKnockoutRounds,
      'stages': stages.map((e) => e.toJson()).toList(),
    };
  }

  factory CompetitionConfig.fromJson(Map<String, dynamic> json) {
    final rawTournaments = json['tournaments'];

    final tournaments = rawTournaments is List
        ? rawTournaments
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
        : const <String>['Único'];

    final cleanType = (json['type'] ?? 'single').toString().trim();

    final legacyMode = cleanType == 'local'
        ? 'split_fixture'
        : 'single_fixture';

    final mode = (json['mode'] ?? legacyMode).toString().trim();

    final hasFixture = json['hasFixture'] is bool
        ? json['hasFixture'] == true
        : mode != 'loose_matches';

    final allowManualMatches = json['allowManualMatches'] is bool
        ? json['allowManualMatches'] == true
        : true;

    final allowKnockoutRounds = json['allowKnockoutRounds'] is bool
        ? json['allowKnockoutRounds'] == true
        : mode == 'single_fixture' || mode == 'phased_fixture';

    final rawStages = json['stages'];

    final stages = rawStages is List
        ? rawStages
            .whereType<Map>()
            .map((e) => CompetitionStageConfig.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .where((e) => e.name.trim().isNotEmpty)
            .toList()
        : <CompetitionStageConfig>[];

    final resolvedTournaments = tournaments.isEmpty
        ? cleanType == 'local'
            ? const ['Apertura', 'Clausura']
            : const ['Único']
        : tournaments;

    final resolvedStages = stages.isNotEmpty
        ? stages
        : List.generate(resolvedTournaments.length, (index) {
            final name = resolvedTournaments[index];

            return CompetitionStageConfig(
              id: _stageIdFromName(name),
              name: name,
              order: index,
              hasFixture: hasFixture,
              allowManualMatches: allowManualMatches,
              allowKnockoutRounds: allowKnockoutRounds,
              stageType: mode == 'loose_matches'
                  ? 'friendly'
                  : mode == 'phased_fixture'
                      ? 'phase'
                      : 'league',
            );
          });

    return CompetitionConfig(
      name: (json['name'] ?? '').toString().trim(),
      type: cleanType,
      tournaments: resolvedTournaments,
      mode: mode,
      hasFixture: hasFixture,
      allowManualMatches: allowManualMatches,
      allowKnockoutRounds: allowKnockoutRounds,
      stages: resolvedStages,
    );
  }

  CompetitionConfig copyWith({
    String? name,
    String? type,
    List<String>? tournaments,
    String? mode,
    bool? hasFixture,
    bool? allowManualMatches,
    bool? allowKnockoutRounds,
    List<CompetitionStageConfig>? stages,
  }) {
    return CompetitionConfig(
      name: name ?? this.name,
      type: type ?? this.type,
      tournaments: tournaments ?? this.tournaments,
      mode: mode ?? this.mode,
      hasFixture: hasFixture ?? this.hasFixture,
      allowManualMatches: allowManualMatches ?? this.allowManualMatches,
      allowKnockoutRounds: allowKnockoutRounds ?? this.allowKnockoutRounds,
      stages: stages ?? this.stages,
    );
  }

  static String _stageIdFromName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }
}

class StructureRepository {
  String _cleanText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalize(String value) {
    return _cleanText(value).toLowerCase();
  }

  List<String> _cleanStringList(List<String> values) {
    final result = <String>[];

    for (final value in values) {
      final clean = _cleanText(value);
      if (clean.isEmpty) continue;

      final exists = result.any((e) => _normalize(e) == _normalize(clean));
      if (!exists) result.add(clean);
    }

    result.sort((a, b) => a.compareTo(b));
    return result;
  }

  Future<List<String>> getSeasons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.seasons);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return _cleanStringList(decoded.map((e) => e.toString()).toList());
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSeasons(List<String> seasons) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppStorageKeys.seasons,
      jsonEncode(_cleanStringList(seasons)),
    );
  }

  Future<bool> addSeason(String season) async {
    final clean = _cleanText(season);
    if (clean.isEmpty) return false;

    final seasons = await getSeasons();
    final exists = seasons.any((e) => _normalize(e) == _normalize(clean));

    if (exists) return false;

    await saveSeasons([...seasons, clean]);
    return true;
  }

  Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.categories);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return _cleanStringList(decoded.map((e) => e.toString()).toList());
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppStorageKeys.categories,
      jsonEncode(_cleanStringList(categories)),
    );
  }

  Future<bool> addCategory(String category) async {
    final clean = _cleanText(category);
    if (clean.isEmpty) return false;

    final categories = await getCategories();
    final exists = categories.any((e) => _normalize(e) == _normalize(clean));

    if (exists) return false;

    await saveCategories([...categories, clean]);
    return true;
  }

  Future<List<CompetitionConfig>> getCompetitions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.competitions);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final result = <CompetitionConfig>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        final competition = CompetitionConfig.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (competition.name.isEmpty) continue;

        final exists = result.any(
          (e) => _normalize(e.name) == _normalize(competition.name),
        );

        if (!exists) result.add(competition);
      }

      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCompetitions(List<CompetitionConfig> competitions) async {
    final prefs = await SharedPreferences.getInstance();

    final result = <CompetitionConfig>[];

    for (final competition in competitions) {
      final cleanName = _cleanText(competition.name);
      if (cleanName.isEmpty) continue;

      final exists = result.any(
        (e) => _normalize(e.name) == _normalize(cleanName),
      );

      if (exists) continue;

      result.add(
        competition.copyWith(
          name: cleanName,
          type: competition.type.trim().isEmpty ? 'single' : competition.type,
          tournaments: _cleanStringList(competition.tournaments).isEmpty
              ? const ['Único']
              : _cleanStringList(competition.tournaments),
        ),
      );
    }

    result.sort((a, b) => a.name.compareTo(b.name));

    await prefs.setString(
      AppStorageKeys.competitions,
      jsonEncode(result.map((e) => e.toJson()).toList()),
    );
  }

    Future<bool> addCompetition({
    required String name,
    required String type,
    List<String>? tournaments,
    String? mode,
    bool? hasFixture,
    bool? allowManualMatches,
    bool? allowKnockoutRounds,
    List<CompetitionStageConfig>? stages,
  }) async {
    final cleanName = _cleanText(name);
    if (cleanName.isEmpty) return false;

    final competitions = await getCompetitions();

    final exists = competitions.any(
      (e) => _normalize(e.name) == _normalize(cleanName),
    );

    if (exists) return false;

    final cleanMode = _cleanText(mode ?? '').isEmpty
        ? type == 'local'
            ? 'split_fixture'
            : 'single_fixture'
        : _cleanText(mode!);

    final cleanType = _cleanText(type).isEmpty
        ? cleanMode == 'split_fixture'
            ? 'local'
            : 'single'
        : _cleanText(type);

    final resolvedHasFixture = hasFixture ?? cleanMode != 'loose_matches';

    final resolvedAllowManualMatches = allowManualMatches ?? true;

    final resolvedAllowKnockoutRounds =
        allowKnockoutRounds ?? cleanMode == 'single_fixture';

    final resolvedTournaments = tournaments == null || tournaments.isEmpty
        ? cleanMode == 'split_fixture'
            ? const ['Apertura', 'Clausura']
            : cleanMode == 'loose_matches'
                ? const ['Partidos sueltos']
                : const ['Único']
        : _cleanStringList(tournaments);

    final resolvedStages = stages == null || stages.isEmpty
        ? List.generate(resolvedTournaments.length, (index) {
            final stageName = resolvedTournaments[index];

            return CompetitionStageConfig(
              id: CompetitionConfig._stageIdFromName(stageName),
              name: stageName,
              order: index,
              hasFixture: resolvedHasFixture,
              allowManualMatches: resolvedAllowManualMatches,
              allowKnockoutRounds: resolvedAllowKnockoutRounds,
              stageType: cleanMode == 'loose_matches'
                  ? 'friendly'
                  : cleanMode == 'phased_fixture'
                      ? 'phase'
                      : 'league',
            );
          })
        : stages;

    await saveCompetitions([
      ...competitions,
      CompetitionConfig(
        name: cleanName,
        type: cleanType,
        tournaments: resolvedTournaments,
        mode: cleanMode,
        hasFixture: resolvedHasFixture,
        allowManualMatches: resolvedAllowManualMatches,
        allowKnockoutRounds: resolvedAllowKnockoutRounds,
        stages: resolvedStages,
      ),
    ]);

    return true;
  }
  
  Future<bool> addTournamentToCompetition({
    required String competitionName,
    required String tournament,
  }) async {
    final cleanCompetitionName = _cleanText(competitionName);
    final cleanTournament = _cleanText(tournament);

    if (cleanCompetitionName.isEmpty || cleanTournament.isEmpty) return false;

    final competitions = await getCompetitions();

    final index = competitions.indexWhere(
      (e) => _normalize(e.name) == _normalize(cleanCompetitionName),
    );

    if (index < 0) return false;

    final current = competitions[index];

    final exists = current.tournaments.any(
      (e) => _normalize(e) == _normalize(cleanTournament),
    );

    if (exists) return false;

    final updated = current.copyWith(
      tournaments: _cleanStringList([...current.tournaments, cleanTournament]),
    );

    final newList = [...competitions];
    newList[index] = updated;

    await saveCompetitions(newList);
    return true;
  }

  Future<void> ensureInitialStructureFromActiveContext({
    required String season,
    required String competition,
    required String tournament,
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanSeason = _cleanText(season);
    final cleanCompetition = _cleanText(competition);
    final cleanTournament = _cleanText(tournament);
    final cleanCategory = _cleanText(category);

    if (cleanSeason.isNotEmpty) {
      await addSeason(cleanSeason);
    }

    final detectedCategories = <String>{};

    if (cleanCategory.isNotEmpty) {
      detectedCategories.add(cleanCategory);
    }

    for (final key in prefs.getKeys()) {
      if (!key.startsWith('roster_')) continue;

      final parts = key.split('_');
      if (parts.length < 3) continue;

      final detectedSeason = parts[1].trim();
      final detectedCategory = parts.sublist(2).join('_').trim();

      if (detectedSeason == cleanSeason && detectedCategory.isNotEmpty) {
        detectedCategories.add(detectedCategory);
      }
    }

    final currentCategories = await getCategories();
    await saveCategories([...currentCategories, ...detectedCategories]);

    if (cleanCompetition.isNotEmpty) {
      final isLocal = _normalize(cleanCompetition) == 'local';

      await addCompetition(
        name: cleanCompetition,
        type: isLocal ? 'local' : 'single',
        tournaments: isLocal
            ? const ['Apertura', 'Clausura']
            : [cleanTournament.isEmpty ? 'Único' : cleanTournament],
      );
    }
  }
}