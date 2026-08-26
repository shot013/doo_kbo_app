import 'package:equatable/equatable.dart';

import 'best_performer.dart';
import 'pitcher_decision.dart';

class GameResult extends Equatable {
  const GameResult({
    required this.gameId,
    required this.gameDate,
    required this.stadium,
    required this.homeTeamCode,
    required this.homeTeamName,
    required this.awayTeamCode,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.bestPerformer,
    required this.pitchers,
  });

  final String gameId;
  final String gameDate;
  final String? stadium;
  final String homeTeamCode;
  final String homeTeamName;
  final String awayTeamCode;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final BestPerformer? bestPerformer;
  final List<PitcherDecision> pitchers;

  /// 표시용 짧은 팀명 (예: "LG 트윈스" -> "LG").
  String get homeTeamVisibleName => homeTeamName.split(' ').first;
  String get awayTeamVisibleName => awayTeamName.split(' ').first;

  @override
  List<Object?> get props => [
    gameId,
    gameDate,
    stadium,
    homeTeamCode,
    homeTeamName,
    awayTeamCode,
    awayTeamName,
    homeScore,
    awayScore,
    bestPerformer,
    pitchers,
  ];

  List<PitcherDecision> getPitchersByTeam(String teamCode) {
    return pitchers.where((pitcher) => pitcher.teamCode == teamCode).toList();
  }
}
