import '../../domain/entities/pitcher_matchup.dart';

final class PitcherMatchupModel extends PitcherMatchup {
  const PitcherMatchupModel({
    required super.style,
    required super.seasonRecord,
    required super.headToHeadRecord,
    required super.era,
    required super.war,
    required super.games,
    required super.avgInnings,
    required super.qualityStarts,
    required super.whip,
  });

  factory PitcherMatchupModel.homeFromJson(Map<String, dynamic> json) {
    return PitcherMatchupModel(
      style: json['homePitcherStyle'] as String?,
      seasonRecord: json['homePitcherSeasonRecord'] as String?,
      headToHeadRecord: json['homePitcherHeadToHeadRecord'] as String?,
      era: json['homePitcherEra'] as String?,
      war: json['homePitcherWar'] as String?,
      games: json['homePitcherGames'] as String?,
      avgInnings: json['homePitcherAvgInnings'] as String?,
      qualityStarts: json['homePitcherQualityStarts'] as String?,
      whip: json['homePitcherWhip'] as String?,
    );
  }

  factory PitcherMatchupModel.awayFromJson(Map<String, dynamic> json) {
    return PitcherMatchupModel(
      style: json['awayPitcherStyle'] as String?,
      seasonRecord: json['awayPitcherSeasonRecord'] as String?,
      headToHeadRecord: json['awayPitcherHeadToHeadRecord'] as String?,
      era: json['awayPitcherEra'] as String?,
      war: json['awayPitcherWar'] as String?,
      games: json['awayPitcherGames'] as String?,
      avgInnings: json['awayPitcherAvgInnings'] as String?,
      qualityStarts: json['awayPitcherQualityStarts'] as String?,
      whip: json['awayPitcherWhip'] as String?,
    );
  }
}
