import 'package:equatable/equatable.dart';

/// 상대 투수별 기록 한 줄 (타자 전용).
class PlayerVsPitcherStat extends Equatable {
  const PlayerVsPitcherStat({
    required this.pitcherId,
    required this.pitcherName,
    required this.pitcherTeamCode,
    required this.atBats,
    required this.hits,
    required this.avg,
  });

  final int pitcherId;
  final String pitcherName;
  final String pitcherTeamCode;
  final int atBats;
  final int hits;
  final String avg;

  @override
  List<Object?> get props => [
    pitcherId,
    pitcherName,
    pitcherTeamCode,
    atBats,
    hits,
    avg,
  ];
}
