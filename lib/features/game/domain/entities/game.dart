import 'package:equatable/equatable.dart';

import 'game_status.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.seasonYear,
    required this.gameDate,
    required this.scheduledAt,
    required this.stadium,
    required this.homeTeamCode,
    required this.homeTeamName,
    required this.awayTeamCode,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.currentInning,
    required this.status,
  });

  final String id;
  final int seasonYear;
  final String gameDate;
  final DateTime scheduledAt;
  final String? stadium;
  final String homeTeamCode;
  final String homeTeamName;
  final String awayTeamCode;
  final String awayTeamName;
  final int? homeScore;
  final int? awayScore;
  final String? currentInning;
  final GameStatus status;

  @override
  List<Object?> get props => [
    id,
    seasonYear,
    gameDate,
    scheduledAt,
    stadium,
    homeTeamCode,
    homeTeamName,
    awayTeamCode,
    awayTeamName,
    homeScore,
    awayScore,
    currentInning,
    status,
  ];
}
