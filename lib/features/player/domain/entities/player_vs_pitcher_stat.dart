import 'package:equatable/equatable.dart';

/// 상대 투수별 기록 한 줄 (타자 전용).
class PlayerVsPitcherStat extends Equatable {
  const PlayerVsPitcherStat({
    required this.pitcherName,
    required this.pitcherTeamCode,
    required this.pitcherTeamName,
    required this.games,
    required this.avg,
  });

  final String pitcherName;
  final String pitcherTeamCode;
  final String pitcherTeamName;
  final int games;
  final String avg;

  @override
  List<Object?> get props => [
    pitcherName,
    pitcherTeamCode,
    pitcherTeamName,
    games,
    avg,
  ];
}
