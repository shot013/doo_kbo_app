import '../../domain/entities/game.dart';
import '../../domain/entities/game_status.dart';

final class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.seasonYear,
    required super.gameDate,
    required super.scheduledAt,
    required super.stadium,
    required super.homeTeamCode,
    required super.homeTeamName,
    required super.awayTeamCode,
    required super.awayTeamName,
    required super.homeScore,
    required super.awayScore,
    required super.currentInning,
    required super.status,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      seasonYear: json['seasonYear'] as int,
      gameDate: json['gameDate'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      stadium: json['stadium'] as String?,
      homeTeamCode: json['homeTeamCode'] as String,
      homeTeamName: json['homeTeamName'] as String,
      awayTeamCode: json['awayTeamCode'] as String,
      awayTeamName: json['awayTeamName'] as String,
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      currentInning: json['currentInning'] as String?,
      status: _statusFromJson(json['status'] as String),
    );
  }

  static GameStatus _statusFromJson(String value) {
    return switch (value) {
      'SCHEDULED' => GameStatus.scheduled,
      'IN_PROGRESS' => GameStatus.inProgress,
      'FINISHED' => GameStatus.finished,
      'CANCELLED' => GameStatus.cancelled,
      'POSTPONED' => GameStatus.postponed,
      _ => throw ArgumentError('Unknown GameStatus: $value'),
    };
  }
}
