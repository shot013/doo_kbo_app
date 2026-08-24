import 'package:equatable/equatable.dart';

/// 상대 구단별 기록 한 줄 (타자는 상대 타율, 투수는 피안타율).
class PlayerVsTeamStat extends Equatable {
  const PlayerVsTeamStat({
    required this.teamCode,
    required this.teamName,
    required this.games,
    required this.avg,
  });

  final String teamCode;
  final String teamName;
  final int games;
  final String avg;

  @override
  List<Object?> get props => [teamCode, teamName, games, avg];
}
