import '../../domain/entities/team_summary.dart';

final class TeamSummaryModel extends TeamSummary {
  const TeamSummaryModel({
    required super.teamCode,
    required super.teamName,
    required super.rank,
    required super.wins,
    required super.losses,
    required super.draws,
    required super.winRate,
    required super.gamesBehind,
    required super.battingAverage,
    required super.era,
    required super.runsScored,
    required super.runsAllowed,
    required super.recentForm,
  });

  factory TeamSummaryModel.fromJson(Map<String, dynamic> json) {
    final recentFormJson = json['recentForm'] as List<dynamic>? ?? const [];
    return TeamSummaryModel(
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      rank: json['rank'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      winRate: json['winRate'] as String,
      gamesBehind: json['gamesBehind'] as String,
      battingAverage: json['battingAverage'] as String,
      era: json['era'] as String,
      runsScored: json['runsScored'] as int,
      runsAllowed: json['runsAllowed'] as int,
      recentForm: recentFormJson.cast<String>(),
    );
  }
}
