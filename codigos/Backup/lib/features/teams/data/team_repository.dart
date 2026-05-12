import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';

class TeamModel {
  final String id;
  final String name;
  final String normalizedName;
  final String? shortName;

  // Escudo incluido en assets de la app
  final String? shieldAsset;

  // Escudo subido por usuario (archivo local)
  final String? shieldFilePath;

  final bool isOwnTeam;
  final bool isActive;

  const TeamModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.shortName,
    this.shieldAsset,
    this.shieldFilePath,
    this.isOwnTeam = false,
    this.isActive = true,
  });

  factory TeamModel.create({
    required String name,
    String? shortName,
    String? shieldAsset,
    String? shieldFilePath,
    bool isOwnTeam = false,
  }) {
    final normalized = TeamRepository.normalize(name);

    return TeamModel(
      id: TeamRepository.idFromName(name),
      name: name.trim(),
      normalizedName: normalized,
      shortName: _cleanNullable(shortName),
      shieldAsset: _cleanNullable(shieldAsset),
      shieldFilePath: _cleanNullable(shieldFilePath),
      isOwnTeam: isOwnTeam,
      isActive: true,
    );
  }

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString().trim();

    return TeamModel(
      id: (json['id'] ?? TeamRepository.idFromName(name)).toString().trim(),
      name: name,
      normalizedName: (json['normalizedName'] ?? TeamRepository.normalize(name))
          .toString()
          .trim(),
      shortName: _cleanNullable(json['shortName']),
      shieldAsset: _cleanNullable(json['shieldAsset']),
      shieldFilePath: _cleanNullable(json['shieldFilePath']),
      isOwnTeam: json['isOwnTeam'] == true,
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'shortName': shortName,
      'shieldAsset': shieldAsset,
      'shieldFilePath': shieldFilePath,
      'isOwnTeam': isOwnTeam,
      'isActive': isActive,
    };
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? shortName,
    String? shieldAsset,
    String? shieldFilePath,
    bool? isOwnTeam,
    bool? isActive,
  }) {
    final resolvedName = name ?? this.name;

    return TeamModel(
      id: id ?? this.id,
      name: resolvedName,
      normalizedName: normalizedName ?? TeamRepository.normalize(resolvedName),
      shortName: shortName ?? this.shortName,
      shieldAsset: shieldAsset ?? this.shieldAsset,
      shieldFilePath: shieldFilePath ?? this.shieldFilePath,
      isOwnTeam: isOwnTeam ?? this.isOwnTeam,
      isActive: isActive ?? this.isActive,
    );
  }

  String? get displayShieldPath {
    final asset = _cleanNullable(shieldAsset);

    if (asset != null) {
      return asset;
    }

    return _cleanNullable(shieldFilePath);
  }

  static String? _cleanNullable(dynamic value) {
    final text = (value ?? '').toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }
}

class TeamRepository {
  const TeamRepository();

  static String normalize(dynamic value) {
    return (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String idFromName(String value) {
    return normalize(
      value,
    ).replaceAll(RegExp(r'\s+'), '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  Future<List<TeamModel>> readTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.teams);

    if (raw == null || raw.trim().isEmpty || raw.trim() == 'null') {
      final seeded = _defaultTeams();
      await saveTeams(seeded);
      return seeded;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        await prefs.remove(AppStorageKeys.teams);
        final seeded = _defaultTeams();
        await saveTeams(seeded);
        return seeded;
      }

      final result = <TeamModel>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        final team = TeamModel.fromJson(Map<String, dynamic>.from(item));

        if (team.name.trim().isEmpty) continue;

        final exists = result.any(
          (e) => e.normalizedName == team.normalizedName,
        );

        if (!exists) result.add(team);
      }

      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    } catch (_) {
      await prefs.remove(AppStorageKeys.teams);
      final seeded = _defaultTeams();
      await saveTeams(seeded);
      return seeded;
    }
  }

  Future<void> saveTeams(List<TeamModel> teams) async {
    final prefs = await SharedPreferences.getInstance();

    final result = <TeamModel>[];

    for (final team in teams) {
      if (team.name.trim().isEmpty) continue;

      final exists = result.any((e) => e.normalizedName == team.normalizedName);

      if (!exists) result.add(team);
    }

    result.sort((a, b) => a.name.compareTo(b.name));

    await prefs.setString(
      AppStorageKeys.teams,
      jsonEncode(result.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> addTeam({
    required String name,
    String? shortName,
    String? shieldAsset,
    String? shieldFilePath,
    bool isOwnTeam = false,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return false;

    final teams = await readTeams();
    final normalized = normalize(cleanName);

    final exists = teams.any((e) => e.normalizedName == normalized);
    if (exists) return false;

    await saveTeams([
      ...teams,
      TeamModel.create(
        name: cleanName,
        shortName: shortName,
        shieldAsset: shieldAsset,
        shieldFilePath: shieldFilePath,
        isOwnTeam: isOwnTeam,
      ),
    ]);

    return true;
  }

  Future<TeamModel?> findByName(String name) async {
    final normalized = normalize(name);
    if (normalized.isEmpty) return null;

    final teams = await readTeams();

    for (final team in teams) {
      if (team.normalizedName == normalized) return team;
      if (normalize(team.shortName) == normalized) return team;
    }

    return null;
  }

  Future<String?> shieldForTeamName(String name) async {
    final team = await findByName(name);
    return team?.displayShieldPath;
  }

  List<TeamModel> _defaultTeams() {
    return const [
      TeamModel(
        id: 'san_fernando_handball',
        name: 'San Fernando Handball',
        normalizedName: 'san fernando handball',
        shortName: 'San Fernando',
        shieldAsset: 'assets/images/san_fernando.png',
        isOwnTeam: true,
        isActive: true,
      ),
      TeamModel(
        id: 'municipalidad_de_vicente_lopez',
        name: 'Municipalidad de Vicente Lopez',
        normalizedName: 'municipalidad de vicente lopez',
      ),
      TeamModel(
        id: 'colegio_ward',
        name: 'Colegio Ward',
        normalizedName: 'colegio ward',
      ),
      TeamModel(
        id: 'sag_villa_ballester',
        name: 'S.A.G. Villa Ballester',
        normalizedName: 's.a.g. villa ballester',
      ),
      TeamModel(
        id: 'argentinos_juniors',
        name: 'Argentinos Juniors',
        normalizedName: 'argentinos juniors',
      ),
      TeamModel(
        id: 'ferro_carril_oeste',
        name: 'Ferro Carril Oeste',
        normalizedName: 'ferro carril oeste',
      ),
      TeamModel(
        id: 'ca_velez_sarsfield',
        name: 'C.A. Velez Sarsfield',
        normalizedName: 'c.a. velez sarsfield',
      ),
      TeamModel(
        id: 'campana_boat_club',
        name: 'Campana Boat Club',
        normalizedName: 'campana boat club',
      ),
      TeamModel(id: 'sagab', name: 'S.A.G.A.B.', normalizedName: 's.a.g.a.b.'),
      TeamModel(
        id: 'ca_river_plate',
        name: 'C.A. River Plate',
        normalizedName: 'c.a. river plate',
      ),
      TeamModel(
        id: 'dorrego_handball',
        name: 'Dorrego Handball',
        normalizedName: 'dorrego handball',
      ),
      TeamModel(
        id: 'estudiantes_de_la_plata',
        name: 'Estudiantes de La Plata',
        normalizedName: 'estudiantes de la plata',
      ),
      TeamModel(
        id: 'sedalo',
        name: 'S.E.D.A.L.O.',
        normalizedName: 's.e.d.a.l.o.',
      ),
      TeamModel(
        id: 'ca_lanus',
        name: 'C.A. Lanus',
        normalizedName: 'c.a. lanus',
      ),
      TeamModel(
        id: 'nuestra_senora_de_lujan',
        name: 'Nuestra Senora de Luján',
        normalizedName: 'nuestra senora de lujan',
      ),
      TeamModel(
        id: 'aacf_quilmes',
        name: 'A.A.C.F. Quilmes',
        normalizedName: 'a.a.c.f. quilmes',
      ),
    ];
  }

  Future<bool> updateTeamShieldFilePath({
    required String teamId,
    required String shieldFilePath,
  }) async {
    final cleanPath = shieldFilePath.trim();
    if (teamId.trim().isEmpty || cleanPath.isEmpty) return false;

    final teams = await readTeams();

    final index = teams.indexWhere((team) => team.id == teamId);
    if (index < 0) return false;

    final current = teams[index];

    final updated = <TeamModel>[...teams];
    updated[index] = current.copyWith(shieldFilePath: cleanPath);

    await saveTeams(updated);
    return true;
  }
}
