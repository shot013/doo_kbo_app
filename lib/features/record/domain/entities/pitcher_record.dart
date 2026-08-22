import 'package:equatable/equatable.dart';

class PitcherRecord extends Equatable {
  const PitcherRecord({
    required this.rank,
    required this.playerId,
    required this.playerName,
    required this.teamCode,
    required this.teamName,
    required this.era,
    required this.games,
    required this.wins,
    required this.losses,
    required this.saves,
  });

  final int rank;
  final String playerId;
  final String playerName;
  final String teamCode;
  final String teamName;
  final String era;
  final int games;
  final int wins;
  final int losses;
  final int saves;

  @override
  List<Object?> get props => [
    rank,
    playerId,
    playerName,
    teamCode,
    teamName,
    era,
    games,
    wins,
    losses,
    saves,
  ];
}
