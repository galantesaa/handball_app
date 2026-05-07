import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';

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

    final tournaments = rawTournaments is List
        ? rawTournaments
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
        : const <String>['Único'];

    return CompetitionConfig(
      name: (json['name'] ?? '').toString().trim(),
      type: (json['type'] ?? 'single').toString().trim(),
      tournaments: tournaments.isEmpty ? const ['Único'] : tournaments,
    );
  }

  CompetitionConfig copyWith({
    String? name,
    String? type,
    List<String>? tournaments,
  }) {
    return CompetitionConfig(
      name: name ?? this.name,
      type: type ?? this.type,
      tournaments: tournaments ?? this.tournaments,
    );
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
  }) async {
    final cleanName = _cleanText(name);
    if (cleanName.isEmpty) return false;

    final competitions = await getCompetitions();

    final exists = competitions.any(
      (e) => _normalize(e.name) == _normalize(cleanName),
    );

    if (exists) return false;

    final cleanType = _cleanText(type).isEmpty ? 'single' : _cleanText(type);

    final resolvedTournaments = tournaments == null || tournaments.isEmpty
        ? cleanType == 'local'
            ? const ['Apertura', 'Clausura']
            : const ['Único']
        : _cleanStringList(tournaments);

    await saveCompetitions([
      ...competitions,
      CompetitionConfig(
        name: cleanName,
        type: cleanType,
        tournaments: resolvedTournaments,
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