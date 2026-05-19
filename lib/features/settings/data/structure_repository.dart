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

  CompetitionStageConfig copyWith({
    String? id,
    String? name,
    int? order,
    bool? hasFixture,
    bool? allowManualMatches,
    bool? allowKnockoutRounds,
    String? stageType,
  }) {
    return CompetitionStageConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      hasFixture: hasFixture ?? this.hasFixture,
      allowManualMatches: allowManualMatches ?? this.allowManualMatches,
      allowKnockoutRounds: allowKnockoutRounds ?? this.allowKnockoutRounds,
      stageType: stageType ?? this.stageType,
    );
  }
}

class CompetitionConfig {
  final String name;

  /// Compatibilidad legacy:
  /// - local
  /// - single
  final String type;

  /// Compatibilidad legacy.
  final List<String> tournaments;

  /// Nuevo modelo:
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

    final resolvedTournaments = tournaments.isEmpty
        ? cleanType == 'local'
              ? const ['Apertura', 'Clausura']
              : mode == 'loose_matches'
              ? const ['Partidos sueltos']
              : const ['Único']
        : tournaments;

    final rawStages = json['stages'];

    final stages = rawStages is List
        ? rawStages
              .whereType<Map>()
              .map(
                (e) => CompetitionStageConfig.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .where((e) => e.name.trim().isNotEmpty)
              .toList()
        : <CompetitionStageConfig>[];

    final resolvedStages = stages.isNotEmpty
        ? stages
        : List.generate(resolvedTournaments.length, (index) {
            final stageName = resolvedTournaments[index];

            return CompetitionStageConfig(
              id: StructureRepository.stageIdFromName(stageName),
              name: stageName,
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
}

class StructureRepository {
  String _cleanText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalize(String value) {
    return _cleanText(value)
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  String _canonicalCategoryName(String value) {
    final clean = _cleanText(value);
    final normalized = _normalize(clean);

    if (normalized.isEmpty) return '';

    const canonicalByAlias = <String, String>{
      'mini': 'Mini',
      'minis': 'Mini',

      'infantil': 'Infantiles',
      'infantiles': 'Infantiles',

      'menor': 'Menores',
      'menores': 'Menores',

      'cadete': 'Cadetes',
      'cadetes': 'Cadetes',

      'juvenil': 'Juveniles',
      'juveniles': 'Juveniles',

      'junior': 'Juniors',
      'juniors': 'Juniors',

      'mayor': 'Mayores',
      'mayores': 'Mayores',
      'primera': 'Mayores',
      'liga': 'Mayores',
    };

    return canonicalByAlias[normalized] ?? clean;
  }

  List<String> _cleanCategoryList(List<String> values) {
    final result = <String>[];

    for (final value in values) {
      final clean = _canonicalCategoryName(value);

      if (clean.isEmpty) continue;

      final exists = result.any((e) => _normalize(e) == _normalize(clean));

      if (!exists) {
        result.add(clean);
      }
    }

    result.sort((a, b) {
      const order = <String, int>{
        'Mini': 0,
        'Infantiles': 1,
        'Menores': 2,
        'Cadetes': 3,
        'Juveniles': 4,
        'Juniors': 5,
        'Mayores': 6,
      };

      final orderA = order[a];
      final orderB = order[b];

      if (orderA != null && orderB != null) return orderA.compareTo(orderB);
      if (orderA != null) return -1;
      if (orderB != null) return 1;

      return a.compareTo(b);
    });

    return result;
  }

  String _safeInstitutionId(String? institutionId) {
    return (institutionId ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  String _keyFor({required String baseKey, String? institutionId}) {
    final safeId = _safeInstitutionId(institutionId);

    if (safeId.isEmpty) return baseKey;

    return '${baseKey}_$safeId';
  }

  static String stageIdFromName(String value) {
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

  Future<List<String>> getSeasons({String? institutionId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _keyFor(baseKey: AppStorageKeys.seasons, institutionId: institutionId),
    );

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return _cleanStringList(decoded.map((e) => e.toString()).toList());
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSeasons(
    List<String> seasons, {
    String? institutionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _keyFor(baseKey: AppStorageKeys.seasons, institutionId: institutionId),
      jsonEncode(_cleanStringList(seasons)),
    );
  }

  Future<bool> addSeason(String season, {String? institutionId}) async {
    final clean = _cleanText(season);
    if (clean.isEmpty) return false;

    final seasons = await getSeasons(institutionId: institutionId);
    final exists = seasons.any((e) => _normalize(e) == _normalize(clean));

    if (exists) return false;

    await saveSeasons([...seasons, clean], institutionId: institutionId);
    return true;
  }

  Future<List<String>> getCategories({String? institutionId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _keyFor(baseKey: AppStorageKeys.categories, institutionId: institutionId),
    );

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final categories = _cleanCategoryList(
        decoded.map((e) => e.toString()).toList(),
      );

      final encoded = jsonEncode(categories);

      if (encoded != raw) {
        await prefs.setString(
          _keyFor(
            baseKey: AppStorageKeys.categories,
            institutionId: institutionId,
          ),
          encoded,
        );
      }

      return categories;
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCategories(
    List<String> categories, {
    String? institutionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _keyFor(baseKey: AppStorageKeys.categories, institutionId: institutionId),
      jsonEncode(_cleanCategoryList(categories)),
    );
  }

  Future<bool> addCategory(String category, {String? institutionId}) async {
    final clean = _canonicalCategoryName(category);
    if (clean.isEmpty) return false;

    final categories = await getCategories(institutionId: institutionId);

    final exists = categories.any((e) => _normalize(e) == _normalize(clean));

    if (exists) return false;

    await saveCategories([...categories, clean], institutionId: institutionId);
    return true;
  }

  Future<List<CompetitionConfig>> getCompetitions({
    String? institutionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _keyFor(
        baseKey: AppStorageKeys.competitions,
        institutionId: institutionId,
      ),
    );

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

  Future<void> saveCompetitions(
    List<CompetitionConfig> competitions, {
    String? institutionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final result = <CompetitionConfig>[];

    for (final competition in competitions) {
      if (competition.name.trim().isEmpty) continue;

      final exists = result.any(
        (e) => _normalize(e.name) == _normalize(competition.name),
      );

      if (!exists) result.add(competition);
    }

    result.sort((a, b) => a.name.compareTo(b.name));

    await prefs.setString(
      _keyFor(
        baseKey: AppStorageKeys.competitions,
        institutionId: institutionId,
      ),
      jsonEncode(result.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> addCompetition({
    required String name,
    required String type,
    List<String>? tournaments,
    String? mode,
    String? institutionId,
    bool? hasFixture,
    bool? allowManualMatches,
    bool? allowKnockoutRounds,
    List<CompetitionStageConfig>? stages,
  }) async {
    final cleanName = _cleanText(name);
    if (cleanName.isEmpty) return false;

    final competitions = await getCompetitions(institutionId: institutionId);

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
              id: stageIdFromName(stageName),
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
    ], institutionId: institutionId);

    return true;
  }

  Future<bool> addTournamentToCompetition({
    required String competitionName,
    required String tournament,
    String? institutionId,
  }) async {
    final cleanCompetitionName = _cleanText(competitionName);
    final cleanTournament = _cleanText(tournament);

    if (cleanCompetitionName.isEmpty || cleanTournament.isEmpty) return false;

    final competitions = await getCompetitions(institutionId: institutionId);

    final index = competitions.indexWhere(
      (e) => _normalize(e.name) == _normalize(cleanCompetitionName),
    );

    if (index < 0) return false;

    final current = competitions[index];

    final exists = current.tournaments.any(
      (e) => _normalize(e) == _normalize(cleanTournament),
    );

    if (exists) return false;

    final updatedTournaments = _cleanStringList([
      ...current.tournaments,
      cleanTournament,
    ]);

    final updatedStages = [
      ...current.stages,
      CompetitionStageConfig(
        id: stageIdFromName(cleanTournament),
        name: cleanTournament,
        order: current.stages.length,
        hasFixture: current.hasFixture,
        allowManualMatches: current.allowManualMatches,
        allowKnockoutRounds: current.allowKnockoutRounds,
        stageType: current.isLooseMatches ? 'friendly' : 'league',
      ),
    ];

    final updated = current.copyWith(
      tournaments: updatedTournaments,
      stages: updatedStages,
    );

    final newList = [...competitions];
    newList[index] = updated;

    await saveCompetitions(newList, institutionId: institutionId);

    return true;
  }

  Future<void> ensureInitialStructureFromActiveContext({
    required String season,
    required String competition,
    required String tournament,
    String? institutionId,
    required String category,
  }) async {
    final cleanSeason = _cleanText(season);
    final cleanCompetition = _cleanText(competition);
    final cleanTournament = _cleanText(tournament);
    final cleanCategory = _canonicalCategoryName(category);

    if (cleanSeason.isNotEmpty) {
      final seasons = await getSeasons(institutionId: institutionId);
      final exists = seasons.any(
        (e) => _normalize(e) == _normalize(cleanSeason),
      );
      if (!exists) {
        await saveSeasons([
          ...seasons,
          cleanSeason,
        ], institutionId: institutionId);
      }
    }

    if (cleanCategory.isNotEmpty) {
      final categories = await getCategories(institutionId: institutionId);
      final exists = categories.any(
        (e) => _normalize(e) == _normalize(cleanCategory),
      );
      if (!exists) {
        await saveCategories([
          ...categories,
          cleanCategory,
        ], institutionId: institutionId);
      }
    }

    if (cleanCompetition.isEmpty) return;

    final competitions = await getCompetitions(institutionId: institutionId);
    final exists = competitions.any(
      (c) => _normalize(c.name) == _normalize(cleanCompetition),
    );

    if (exists) return;

    final isLocal = _normalize(cleanCompetition) == 'local';

    final tournaments = isLocal
        ? const ['Apertura', 'Clausura']
        : [cleanTournament.isEmpty ? 'Único' : cleanTournament];

    await addCompetition(
      name: cleanCompetition,
      institutionId: institutionId,
      type: isLocal ? 'local' : 'single',
      tournaments: tournaments,
      mode: isLocal ? 'split_fixture' : 'single_fixture',
      hasFixture: true,
      allowManualMatches: true,
      allowKnockoutRounds: !isLocal,
    );
  }
}
