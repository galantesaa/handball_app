class ActiveContext {
  final bool hasInstitution;
  final String institutionName;
  final String season;
  final String competition;
  final String tournament;
  final String category;

  const ActiveContext({
    required this.hasInstitution,
    required this.institutionName,
    required this.season,
    required this.competition,
    required this.tournament,
    required this.category,
  });

  factory ActiveContext.initialSeed() {
    return const ActiveContext(
      hasInstitution: true,
      institutionName: 'San Fernando Handball',
      season: '2026',
      competition: 'Local',
      tournament: 'Apertura',
      category: 'Cadetes',
    );
  }

  factory ActiveContext.empty() {
    return const ActiveContext(
      hasInstitution: false,
      institutionName: '',
      season: '',
      competition: '',
      tournament: '',
      category: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasInstitution': hasInstitution,
      'institutionName': institutionName,
      'season': season,
      'competition': competition,
      'tournament': tournament,
      'category': category,
    };
  }

  factory ActiveContext.fromJson(Map<String, dynamic> json) {
    return ActiveContext(
      hasInstitution: json['hasInstitution'] == true,
      institutionName: (json['institutionName'] ?? '').toString(),
      season: (json['season'] ?? '').toString(),
      competition: (json['competition'] ?? '').toString(),
      tournament: (json['tournament'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }

  ActiveContext copyWith({
    bool? hasInstitution,
    String? institutionName,
    String? season,
    String? competition,
    String? tournament,
    String? category,
  }) {
    return ActiveContext(
      hasInstitution: hasInstitution ?? this.hasInstitution,
      institutionName: institutionName ?? this.institutionName,
      season: season ?? this.season,
      competition: competition ?? this.competition,
      tournament: tournament ?? this.tournament,
      category: category ?? this.category,
    );
  }
}