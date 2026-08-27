import 'package:equatable/equatable.dart';

/// 상대 타자별 기록 한 줄 (투수 전용).
class PlayerVsBatterStat extends Equatable {
  const PlayerVsBatterStat({
    required this.batterName,
    required this.teamCode,
    required this.teamName,
    required this.games,
    required this.avg,
  });

  final String batterName;
  final String teamCode;
  final String teamName;
  final int games;
  final String avg;

  @override
  List<Object?> get props => [batterName, teamCode, teamName, games, avg];
}
