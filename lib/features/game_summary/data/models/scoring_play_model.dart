import '../../domain/entities/scoring_play.dart';
import 'summary_json_codec.dart';

final class ScoringPlayModel extends ScoringPlay {
  const ScoringPlayModel({
    required super.inning,
    required super.half,
    required super.teamCode,
    required super.description,
    required super.homeScore,
    required super.awayScore,
    required super.isReversal,
    required super.isTying,
  });

  factory ScoringPlayModel.fromJson(Map<String, dynamic> json) {
    return ScoringPlayModel(
      inning: json['inning'] as int,
      half: inningHalfFromJson(json['half']),
      teamCode: json['teamCode'] as String,
      description: json['description'] as String,
      homeScore: json['homeScore'] as int,
      awayScore: json['awayScore'] as int,
      isReversal: json['isReversal'] as bool? ?? false,
      isTying: json['isTying'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'inning': inning,
    'half': inningHalfToJson(half),
    'teamCode': teamCode,
    'description': description,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'isReversal': isReversal,
    'isTying': isTying,
  };
}
