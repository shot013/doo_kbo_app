import '../../domain/entities/standing.dart';

final class StandingModel extends Standing {
  const StandingModel({
    required super.seasonYear,
    required super.teamCode,
    required super.teamName,
    required super.rank,
    required super.gamesPlayed,
    required super.wins,
    required super.losses,
    required super.draws,
    required super.winRate,
    required super.gamesBehind,
    required super.streak,
    required super.last10,
    required super.homeRecord,
    required super.awayRecord,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    return StandingModel(
      seasonYear: json['seasonYear'] as int,
      teamCode: json['teamCode'] as String,
      teamName: json['teamName'] as String,
      rank: json['rank'] as int,
      gamesPlayed: json['gamesPlayed'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      draws: json['draws'] as int,
      winRate: json['winRate'] as String,
      gamesBehind: json['gamesBehind'] as String?,
      streak: json['streak'] as String?,
      last10: json['last10'] as String?,
      homeRecord: json['homeRecord'] as String?,
      awayRecord: json['awayRecord'] as String?,
    );
  }
}
