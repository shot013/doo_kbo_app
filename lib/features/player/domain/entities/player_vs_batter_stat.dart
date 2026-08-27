import 'package:equatable/equatable.dart';

/// 상대 타자별 기록 한 줄 (투수 전용).
class PlayerVsBatterStat extends Equatable {
  const PlayerVsBatterStat({
    required this.batterId,
    required this.batterName,
    required this.batterTeamCode,
    required this.atBats,
    required this.strikeouts,
    required this.strikeoutRate,
  });

  final int batterId;
  final String batterName;
  final String batterTeamCode;
  final int atBats;
  final int strikeouts;
  final String strikeoutRate;

  @override
  List<Object?> get props => [
    batterId,
    batterName,
    batterTeamCode,
    atBats,
    strikeouts,
    strikeoutRate,
  ];
}
