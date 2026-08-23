import 'package:equatable/equatable.dart';

import '../../../../core/constants/player_position.dart';
import 'player_stat_line.dart';
import 'player_vs_team_stat.dart';

class PlayerDetail extends Equatable {
  const PlayerDetail({
    required this.id,
    required this.name,
    required this.teamCode,
    required this.teamName,
    required this.position,
    required this.backNumber,
    required this.statLines,
    required this.vsTeamStats,
  });

  final String id;
  final String name;
  final String teamCode;
  final String teamName;
  final PlayerPosition position;
  final int backNumber;
  final List<PlayerStatLine> statLines;
  final List<PlayerVsTeamStat> vsTeamStats;

  @override
  List<Object?> get props => [
    id,
    name,
    teamCode,
    teamName,
    position,
    backNumber,
    statLines,
    vsTeamStats,
  ];
}
