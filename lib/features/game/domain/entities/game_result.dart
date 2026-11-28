import 'package:equatable/equatable.dart';

import '../../../../core/utils/team_name.dart';
import 'best_performer.dart';
import 'pitcher_decision.dart';
import 'pitcher_decision_type.dart';

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

  String get homeTeamVisibleName => shortTeamName(homeTeamName);
  String get awayTeamVisibleName => shortTeamName(awayTeamName);

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

  /// 경기 요약 점수 카드에 쓰는 팀별 승·패 투수. 예: `승 김직관`. 없으면 null.
  String? winLossPitcherLabel(String teamCode) {
    for (final pitcher in getPitchersByTeam(teamCode)) {
      switch (pitcher.decision) {
        case PitcherDecisionType.win:
          return '승 ${pitcher.playerName}';
        case PitcherDecisionType.loss:
          return '패 ${pitcher.playerName}';
        case PitcherDecisionType.save || PitcherDecisionType.hold:
          continue;
      }
    }
    return null;
  }

  /// 표시명. [teamCode]가 두 팀 중 어느 쪽도 아니면 코드를 그대로 쓴다.
  String visibleNameOf(String teamCode) {
    if (teamCode == homeTeamCode) return homeTeamVisibleName;
    if (teamCode == awayTeamCode) return awayTeamVisibleName;
    return teamCode;
  }
}
