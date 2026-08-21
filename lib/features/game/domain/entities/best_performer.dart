import 'package:equatable/equatable.dart';

class BestPerformer extends Equatable {
  const BestPerformer({
    required this.playerName,
    required this.teamCode,
    required this.atBats,
    required this.hits,
    required this.rbi,
    required this.runs,
    required this.line,
  });

  final String playerName;
  final String teamCode;
  final int atBats;
  final int hits;
  final int rbi;
  final int runs;
  final String line;

  @override
  List<Object?> get props => [
    playerName,
    teamCode,
    atBats,
    hits,
    rbi,
    runs,
    line,
  ];
}
