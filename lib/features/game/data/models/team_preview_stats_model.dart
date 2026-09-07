import '../../domain/entities/team_preview_stats.dart';

final class TeamPreviewStatsModel extends TeamPreviewStats {
  const TeamPreviewStatsModel({
    required super.record,
    required super.recentForm,
    required super.era,
    required super.battingAverage,
    required super.avgRunsScored,
    required super.avgRunsAllowed,
  });

  factory TeamPreviewStatsModel.homeFromJson(Map<String, dynamic> json) {
    return TeamPreviewStatsModel(
      record: json['homeTeamRecord'] as String?,
      recentForm: json['homeRecentForm'] as String?,
      era: json['homeTeamEra'] as String?,
      battingAverage: json['homeTeamBattingAverage'] as String?,
      avgRunsScored: json['homeTeamAvgRunsScored'] as String?,
      avgRunsAllowed: json['homeTeamAvgRunsAllowed'] as String?,
    );
  }

  factory TeamPreviewStatsModel.awayFromJson(Map<String, dynamic> json) {
    return TeamPreviewStatsModel(
      record: json['awayTeamRecord'] as String?,
      recentForm: json['awayRecentForm'] as String?,
      era: json['awayTeamEra'] as String?,
      battingAverage: json['awayTeamBattingAverage'] as String?,
      avgRunsScored: json['awayTeamAvgRunsScored'] as String?,
      avgRunsAllowed: json['awayTeamAvgRunsAllowed'] as String?,
    );
  }
}
