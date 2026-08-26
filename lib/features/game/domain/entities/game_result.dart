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

  /// 표시용 짧은 팀명 (예: "LG 트윈스" -> "LG"). "kt wiz"처럼 구단이 의도적으로
  /// 소문자로 표기하는 브랜드도 있어, 다른 팀과 시각적으로 통일되도록
  /// toUpperCase()를 적용한다 (한글은 대소문자 개념이 없어 영향 없음).
  String get homeTeamVisibleName => homeTeamName.split(' ').first.toUpperCase();
  String get awayTeamVisibleName => awayTeamName.split(' ').first.toUpperCase();

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
