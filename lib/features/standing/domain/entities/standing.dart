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

  /// 표시용 짧은 팀명 (예: "LG 트윈스" -> "LG"). "kt wiz"처럼 구단이 의도적으로
  /// 소문자로 표기하는 브랜드도 있어, 다른 팀과 시각적으로 통일되도록
  /// toUpperCase()를 적용한다 (한글은 대소문자 개념이 없어 영향 없음).
  String get teamVisibleName => teamName.split(' ').first.toUpperCase();

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
