import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/app_storage_keys.dart';

class InstitutionModel {
  final String id;
  final String name;
  final String normalizedName;
  final String? shieldAsset;
  final String? shieldFilePath;
  final bool isActive;
  final String createdAt;

  const InstitutionModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.createdAt,
    this.shieldAsset,
    this.shieldFilePath,
    this.isActive = true,
  });

  factory InstitutionModel.create({
    required String name,
    String? shieldAsset,
    String? shieldFilePath,
  }) {
    final cleanName = name.trim();
    final now = DateTime.now().toIso8601String();

    return InstitutionModel(
      id: InstitutionRepository.idFromName(cleanName),
      name: cleanName,
      normalizedName: InstitutionRepository.normalize(cleanName),
      shieldAsset: _cleanNullable(shieldAsset),
      shieldFilePath: _cleanNullable(shieldFilePath),
      createdAt: now,
      isActive: true,
    );
  }

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString().trim();

    return InstitutionModel(
      id: (json['id'] ?? InstitutionRepository.idFromName(name))
          .toString()
          .trim(),
      name: name,
      normalizedName:
          (json['normalizedName'] ?? InstitutionRepository.normalize(name))
              .toString()
              .trim(),
      shieldAsset: _cleanNullable(json['shieldAsset']),
      shieldFilePath: _cleanNullable(json['shieldFilePath']),
      isActive: json['isActive'] != false,
      createdAt: (json['createdAt'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'shieldAsset': shieldAsset,
      'shieldFilePath': shieldFilePath,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  InstitutionModel copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? shieldAsset,
    String? shieldFilePath,
    bool? isActive,
    String? createdAt,
  }) {
    final resolvedName = name ?? this.name;

    return InstitutionModel(
      id: id ?? this.id,
      name: resolvedName,
      normalizedName:
          normalizedName ?? InstitutionRepository.normalize(resolvedName),
      shieldAsset: shieldAsset ?? this.shieldAsset,
      shieldFilePath: shieldFilePath ?? this.shieldFilePath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String? get displayShieldPath {
    final asset = _cleanNullable(shieldAsset);
    if (asset != null) return asset;

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

class InstitutionRepository {
  const InstitutionRepository();

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
    return normalize(value)
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  Future<List<InstitutionModel>> readInstitutions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppStorageKeys.institutions);

    if (raw == null || raw.trim().isEmpty || raw.trim() == 'null') {
      final seeded = _defaultInstitutions();
      await saveInstitutions(seeded);
      return seeded;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        await prefs.remove(AppStorageKeys.institutions);
        final seeded = _defaultInstitutions();
        await saveInstitutions(seeded);
        return seeded;
      }

      final result = <InstitutionModel>[];

      for (final item in decoded) {
        if (item is! Map) continue;

        final institution = InstitutionModel.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (institution.name.trim().isEmpty) continue;

        final exists = result.any(
          (e) => e.normalizedName == institution.normalizedName,
        );

        if (!exists) result.add(institution);
      }

      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    } catch (_) {
      await prefs.remove(AppStorageKeys.institutions);
      final seeded = _defaultInstitutions();
      await saveInstitutions(seeded);
      return seeded;
    }
  }

  Future<void> saveInstitutions(List<InstitutionModel> institutions) async {
    final prefs = await SharedPreferences.getInstance();

    final result = <InstitutionModel>[];

    for (final institution in institutions) {
      if (institution.name.trim().isEmpty) continue;

      final exists = result.any(
        (e) => e.normalizedName == institution.normalizedName,
      );

      if (!exists) result.add(institution);
    }

    result.sort((a, b) => a.name.compareTo(b.name));

    await prefs.setString(
      AppStorageKeys.institutions,
      jsonEncode(result.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> addInstitution({
    required String name,
    String? shieldAsset,
    String? shieldFilePath,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return false;

    final institutions = await readInstitutions();
    final normalized = normalize(cleanName);

    final exists = institutions.any((e) => e.normalizedName == normalized);
    if (exists) return false;

    await saveInstitutions([
      ...institutions,
      InstitutionModel.create(
        name: cleanName,
        shieldAsset: shieldAsset,
        shieldFilePath: shieldFilePath,
      ),
    ]);

    return true;
  }

  Future<InstitutionModel?> findByName(String name) async {
    final normalized = normalize(name);
    if (normalized.isEmpty) return null;

    final institutions = await readInstitutions();

    for (final institution in institutions) {
      if (institution.normalizedName == normalized) {
        return institution;
      }
    }

    return null;
  }

  Future<InstitutionModel?> findById(String id) async {
    final cleanId = id.trim();
    if (cleanId.isEmpty) return null;

    final institutions = await readInstitutions();

    for (final institution in institutions) {
      if (institution.id == cleanId) {
        return institution;
      }
    }

    return null;
  }

  Future<bool> updateInstitutionShieldFilePath({
    required String institutionId,
    required String shieldFilePath,
  }) async {
    final cleanId = institutionId.trim();
    final cleanPath = shieldFilePath.trim();

    if (cleanId.isEmpty || cleanPath.isEmpty) return false;

    final institutions = await readInstitutions();

    final index = institutions.indexWhere((e) => e.id == cleanId);
    if (index < 0) return false;

    final updated = <InstitutionModel>[...institutions];

    updated[index] = updated[index].copyWith(
      shieldFilePath: cleanPath,
    );

    await saveInstitutions(updated);
    return true;
  }

  List<InstitutionModel> _defaultInstitutions() {
    return const [
      InstitutionModel(
        id: 'san_fernando_handball',
        name: 'San Fernando Handball',
        normalizedName: 'san fernando handball',
        shieldAsset: 'assets/images/san_fernando.png',
        isActive: true,
        createdAt: '2026-01-01T00:00:00.000',
      ),
    ];
  }
}