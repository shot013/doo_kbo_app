import 'package:equatable/equatable.dart';

class BatterRecord extends Equatable {
  const BatterRecord({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.teamCode,
    required this.teamName,
    required this.avg,
    required this.games,
    required this.homeRuns,
    required this.rbi,
  });

  final int rank;
  final String playerId;
  final String playerName;
  final String teamCode;
  final String teamName;
  final String avg;
  final int games;
  final int homeRuns;
  final int rbi;

  @override
  List<Object?> get props => [
    rank,
    playerId,
    playerName,
    teamCode,
    teamName,
    avg,
    games,
    homeRuns,
    rbi,
  ];
}
