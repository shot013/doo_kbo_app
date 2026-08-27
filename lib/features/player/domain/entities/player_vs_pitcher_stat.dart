import 'package:equatable/equatable.dart';

/// 상대 투수별 기록 한 줄 (타자 전용).
class PlayerVsPitcherStat extends Equatable {
  const PlayerVsPitcherStat({
    required this.pitcherName,
    required this.teamCode,
    required this.teamName,
    required this.games,
    required this.avg,
  });

  final String pitcherName;
  final String teamCode;
  final String teamName;
  final int games;
  final String avg;

  @override
  List<Object?> get props => [pitcherName, teamCode, teamName, games, avg];
}
