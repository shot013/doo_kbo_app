import '../../domain/entities/line_score.dart';

final class LineScoreModel extends LineScore {
  const LineScoreModel({
    required super.inningCount,
    required super.away,
    required super.home,
  });

  factory LineScoreModel.fromJson(Map<String, dynamic> json) {
    return LineScoreModel(
      inningCount: json['inningCount'] as int,
      away: TeamLineScoreModel.fromJson(json['away'] as Map<String, dynamic>),
      home: TeamLineScoreModel.fromJson(json['home'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'inningCount': inningCount,
    'away': (away as TeamLineScoreModel).toJson(),
    'home': (home as TeamLineScoreModel).toJson(),
  };
}

final class TeamLineScoreModel extends TeamLineScore {
  const TeamLineScoreModel({
    required super.teamCode,
    required super.innings,
    required super.runs,
    required super.hits,
    required super.errors,
    required super.walks,
  });

  factory TeamLineScoreModel.fromJson(Map<String, dynamic> json) {
    return TeamLineScoreModel(
      teamCode: json['teamCode'] as String,
      innings: (json['innings'] as List<dynamic>)
          .map((runs) => runs as int?)
          .toList(),
      runs: json['runs'] as int,
      hits: json['hits'] as int,
      errors: json['errors'] as int,
      walks: json['walks'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'teamCode': teamCode,
    'innings': innings,
    'runs': runs,
    'hits': hits,
    'errors': errors,
    'walks': walks,
  };
}
