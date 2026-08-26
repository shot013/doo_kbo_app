import 'package:equatable/equatable.dart';

class Standing extends Equatable {
  const Standing({
    required this.seasonYear,
    required this.teamCode,
    required this.teamName,
    required this.rank,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.gamesBehind,
    required this.streak,
    required this.last10,
    required this.homeRecord,
    required this.awayRecord,
  });

  final int seasonYear;
  final String teamCode;
  final String teamName;
  final int rank;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final String winRate;
  final String? gamesBehind;
  final String? streak;
  final String? last10;
  final String? homeRecord;
  final String? awayRecord;

  /// 표시용 짧은 팀명 (예: "LG 트윈스" -> "LG").
  String get teamVisibleName => teamName.split(' ').first;

  @override
  List<Object?> get props => [
    seasonYear,
    teamCode,
    teamName,
    rank,
    gamesPlayed,
    wins,
    losses,
    draws,
    winRate,
    gamesBehind,
    streak,
    last10,
    homeRecord,
    awayRecord,
  ];
}
