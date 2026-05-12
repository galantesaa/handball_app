import '../../features/settings/domain/models/active_context.dart';

class AppContextKey {
  AppContextKey._();

  static String safe(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(RegExp(r'[^a-z0-9_áéíóúñü-]'), '');
  }

  static String fromParts({
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
    String clean(dynamic value) {
      return (value ?? '').toString().trim().toLowerCase();
    }

    final season = clean(data['temporada']).isEmpty
        ? legacySeason
        : clean(data['temporada']);

    final competition = clean(data['competencia']).isEmpty
        ? legacyCompetition
        : clean(data['competencia']);

    return season == clean(context.season) &&
        competition == clean(context.competition) &&
        clean(data['torneo']) == clean(context.tournament) &&
        clean(data['categoria']) == clean(context.category);
  }
}