import 'package:equatable/equatable.dart';

/// 상대 타자별 기록 한 줄 (투수 전용).
class PlayerVsBatterStat extends Equatable {
  const PlayerVsBatterStat({
    required this.batterName,
    required this.batterTeamCode,
    required this.batterTeamName,
    required this.games,
    required this.avg,
  });

  final String batterName;
  final String batterTeamCode;
  final String batterTeamName;
  final int games;
  final String avg;

  @override
  List<Object?> get props => [
    batterName,
    batterTeamCode,
    batterTeamName,
    games,
    avg,
  ];
}
