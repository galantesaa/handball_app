class ActiveContext {
  final String institution;
  final String season;
  final String competition;
  final String category;

  const ActiveContext({
    required this.institution,
    required this.season,
    required this.competition,
    required this.category,
  });

  factory ActiveContext.initial() {
    return const ActiveContext(
      institution: 'San Fernando',
      season: '2026',
      competition: 'Apertura',
      category: 'Cadetes',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'season': season,
      'competition': competition,
      'category': category,
    };
  }

  factory ActiveContext.fromJson(Map<String, dynamic> json) {
    return ActiveContext(
      institution: json['institution']?.toString() ?? '',
      season: json['season']?.toString() ?? '',
      competition: json['competition']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }

  ActiveContext copyWith({
    String? institution,
    String? season,
    String? competition,
    String? category,
  }) {
    return ActiveContext(
      institution: institution ?? this.institution,
      season: season ?? this.season,
      competition: competition ?? this.competition,
      category: category ?? this.category,
    );
  }
}