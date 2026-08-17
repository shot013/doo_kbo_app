import 'package:equatable/equatable.dart';

class TeamSummary extends Equatable {
  const TeamSummary({
    required this.code,
    required this.name,
    required this.rank,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.gamesBehind,
    required this.recentForm,
  });

  final String code;
  final String name;
  final int rank;
  final int wins;
  final int losses;
  final int draws;
  final String winRate;
  final String gamesBehind;

  /// 최근 5경기 결과. 오래된 경기부터 순서대로 'W'/'L'/'D'.
  final List<String> recentForm;

  @override
  List<Object?> get props => [
    code,
    name,
    rank,
    wins,
    losses,
    draws,
    winRate,
    gamesBehind,
    recentForm,
  ];
}
