import 'package:equatable/equatable.dart';

import 'game_status.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.seasonYear,
    required this.gameDate,
    required this.scheduledAt,
    required this.stadium,
    required this.homeTeamCode,
    required this.homeTeamName,
    required this.awayTeamCode,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.homeStarterPitcher,
    required this.awayStarterPitcher,
    required this.currentInning,
    required this.status,
  });

  final String id;
  final int seasonYear;
  final String gameDate;
  final DateTime scheduledAt;
  final String? stadium;
  final String homeTeamCode;
  final String homeTeamName;
  final String awayTeamCode;
  final String awayTeamName;
  final int? homeScore;
  final int? awayScore;
  final String? homeStarterPitcher;
  final String? awayStarterPitcher;
  final String? currentInning;
  final GameStatus status;

  /// 표시용 짧은 팀명 (예: "LG 트윈스" -> "LG"). "kt wiz"처럼 구단이 의도적으로
  /// 소문자로 표기하는 브랜드도 있어, 다른 팀과 시각적으로 통일되도록
  /// toUpperCase()를 적용한다 (한글은 대소문자 개념이 없어 영향 없음).
  String get homeTeamVisibleName => homeTeamName.split(' ').first.toUpperCase();
  String get awayTeamVisibleName => awayTeamName.split(' ').first.toUpperCase();

  @override
  List<Object?> get props => [
    id,
    seasonYear,
    gameDate,
    scheduledAt,
    stadium,
    homeTeamCode,
    homeTeamName,
    awayTeamCode,
    awayTeamName,
    homeScore,
    awayScore,
    homeStarterPitcher,
    awayStarterPitcher,
    currentInning,
    status,
  ];
}
