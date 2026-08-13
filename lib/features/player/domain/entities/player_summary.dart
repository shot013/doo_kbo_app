import 'package:equatable/equatable.dart';

import '../../../../core/constants/player_position.dart';

class PlayerSummary extends Equatable {
  const PlayerSummary({
    required this.id,
    required this.name,
    required this.teamCode,
    required this.teamName,
    required this.position,
    required this.backNumber,
    required this.primaryStat,
  });

  final String id;
  final String name;
  final String teamCode;
  final String teamName;
  final PlayerPosition position;
  final int backNumber;

  /// 목록에 노출할 대표 스탯 한 줄. 예: "타율 .320", "평균자책 3.21"
  final String primaryStat;

  @override
  List<Object?> get props => [
    id,
    name,
    teamCode,
    teamName,
    position,
    backNumber,
    primaryStat,
  ];
}
