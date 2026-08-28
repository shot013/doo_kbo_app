import 'package:equatable/equatable.dart';

class TeamSummary extends Equatable {
  const TeamSummary({
    required this.teamCode,
    required this.teamName,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.gamesBehind,
    required this.battingAverage,
    required this.era,
    required this.runsScored,
    required this.runsAllowed,
    required this.recentForm,
  });

  final String teamCode;
  final String teamName;
  final int rank;
  final int wins;
  final int losses;
  final int draws;
  final String winRate;
  final String gamesBehind;
  final String battingAverage;
  final String era;
  final int runsScored;
  final int runsAllowed;

  /// 최근 5경기 결과. 오래된 경기부터 순서대로 'W'/'L'/'D'.
  final List<String> recentForm;

  @override
  List<Object?> get props => [
    teamCode,
    teamName,
    rank,
    wins,
    losses,
    draws,
    winRate,
    gamesBehind,
    battingAverage,
    era,
    runsScored,
    runsAllowed,
    recentForm,
  ];
}
