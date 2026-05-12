class ActiveContext {
  final String institutionName;

  /// NUEVO
  /// Identificador estable de institución.
  /// Nullable para compatibilidad backward.
  final String? institutionId;

  final bool hasInstitution;

  final String season;

  final String competition;

  final String tournament;

  final String category;

  const ActiveContext({
    required this.institutionName,
    this.institutionId,
    required this.hasInstitution,
    required this.season,
    required this.competition,
    required this.tournament,
    required this.category,
  });

  factory ActiveContext.empty() {
    return const ActiveContext(
      institutionName: '',
      institutionId: null,
      hasInstitution: false,
      season: '',
      competition: '',
      tournament: '',
      category: '',
    );
  }

  factory ActiveContext.initialSeed() {
    return const ActiveContext(
      institutionName: 'San Fernando Handball',
      institutionId: 'san_fernando_handball',
      hasInstitution: true,
      season: '2026',
      competition: 'Local',
      tournament: 'Apertura',
      category: 'Cadetes',
    );
  }

  ActiveContext copyWith({
    String? institutionName,
    String? institutionId,
    bool? hasInstitution,
    String? season,
    String? competition,
    String? tournament,
    String? category,
  }) {
    return ActiveContext(
      institutionName: institutionName ?? this.institutionName,
      institutionId: institutionId ?? this.institutionId,
      hasInstitution: hasInstitution ?? this.hasInstitution,
      season: season ?? this.season,
      competition: competition ?? this.competition,
      tournament: tournament ?? this.tournament,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institutionName': institutionName,
      'institutionId': institutionId,
      'hasInstitution': hasInstitution,
      'season': season,
      'competition': competition,
      'tournament': tournament,
      'category': category,
    };
  }

  factory ActiveContext.fromJson(Map<String, dynamic> json) {
    return ActiveContext(
      institutionName:
          (json['institutionName'] ?? '').toString().trim(),

      /// backward compatible
      institutionId: json['institutionId']?.toString(),

      hasInstitution: json['hasInstitution'] == true,

      season: (json['season'] ?? '').toString().trim(),

      competition:
          (json['competition'] ?? '').toString().trim(),

      tournament:
          (json['tournament'] ?? '').toString().trim(),

      category:
          (json['category'] ?? '').toString().trim(),
    );
  }
}