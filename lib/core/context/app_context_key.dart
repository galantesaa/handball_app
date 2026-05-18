import '../../features/settings/domain/models/active_context.dart';

class AppContextKey {
  AppContextKey._();

  static String safe(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(' ', '_')
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '');
  }

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

  static String normalizeId(dynamic value) {
    return normalize(value)
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  static String _safeNullable(String? value, {required String fallback}) {
    final clean = (value ?? '').trim();

    if (clean.isEmpty || clean.toLowerCase() == 'null') {
      return fallback;
    }

    return clean;
  }

  static bool _isLegacyOrSanFernandoInstitutionId(String? value) {
    final normalized = normalizeId(value);

    return normalized.isEmpty ||
        normalized == 'legacy_institution' ||
        normalized == 'san_fernando' ||
        normalized == 'san_fernando_handball';
  }

  static bool _sameInstitution({
    required dynamic dataInstitutionId,
    required String? contextInstitutionId,
  }) {
    final dataId = normalizeId(dataInstitutionId);
    final contextId = normalizeId(contextInstitutionId);

    final contextIsLegacyOrSanFernando =
        _isLegacyOrSanFernandoInstitutionId(contextId);

    final dataIsLegacyOrSanFernando =
        _isLegacyOrSanFernandoInstitutionId(dataId);

    // Contexto vacío / legacy:
    // solo acepta datos legacy o San Fernando.
    // No debe aceptar Femebal u otra institución nueva.
    if (contextId.isEmpty || contextId == 'legacy_institution') {
      return dataIsLegacyOrSanFernando;
    }

    // San Fernando:
    // mantiene compatibilidad con backups viejos sin institutionId.
    if (contextIsLegacyOrSanFernando) {
      return dataIsLegacyOrSanFernando;
    }

    // Institución nueva:
    // exige institutionId exacto.
    // Un dato vacío o legacy NO puede entrar acá.
    if (dataId.isEmpty || dataId == 'legacy_institution') {
      return false;
    }

    return dataId == contextId;
  }

  static String fromParts({
    String? institutionId,
    required String season,
    required String competition,
    required String tournament,
    required String category,
  }) {
    final resolvedInstitutionId = _safeNullable(
      institutionId,
      fallback: 'legacy_institution',
    );

    return [
      resolvedInstitutionId,
      season,
      competition,
      tournament,
      category,
    ].map(safe).join('_');
  }

  static String legacyFromParts({
    required String season,
    required String competition,
    required String tournament,
    required String category,
  }) {
    return [
      season,
      competition,
      tournament,
      category,
    ].map(safe).join('_');
  }

  static String fromActiveContext(ActiveContext context) {
    return fromParts(
      institutionId: context.institutionId,
      season: context.season,
      competition: context.competition,
      tournament: context.tournament,
      category: context.category,
    );
  }

  static String legacyFromActiveContext(ActiveContext context) {
    return legacyFromParts(
      season: context.season,
      competition: context.competition,
      tournament: context.tournament,
      category: context.category,
    );
  }

  static bool matchesMap({
    required Map<String, dynamic> data,
    required ActiveContext context,
    String legacySeason = '2026',
    String legacyCompetition = 'local',
  }) {
    final sameInstitution = _sameInstitution(
      dataInstitutionId: data['institutionId'],
      contextInstitutionId: context.institutionId,
    );

    if (!sameInstitution) return false;

    final dataSeason = normalize(data['temporada']).isEmpty
        ? normalize(legacySeason)
        : normalize(data['temporada']);

    final dataCompetition = normalize(data['competencia']).isEmpty
        ? normalize(legacyCompetition)
        : normalize(data['competencia']);

    final dataTournament = normalize(data['torneo']);
    final dataCategory = normalize(data['categoria']);

    final contextSeason = normalize(context.season);
    final contextCompetition = normalize(context.competition);
    final contextTournament = normalize(context.tournament);
    final contextCategory = normalize(context.category);

    if (contextSeason.isEmpty ||
        contextCompetition.isEmpty ||
        contextTournament.isEmpty ||
        contextCategory.isEmpty) {
      return false;
    }

    return dataSeason == contextSeason &&
        dataCompetition == contextCompetition &&
        dataTournament == contextTournament &&
        dataCategory == contextCategory;
  }
}