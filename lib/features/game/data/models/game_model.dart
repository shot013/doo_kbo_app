import '../../domain/entities/game.dart';
import '../../domain/entities/game_status.dart';

final class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.seasonYear,
    required super.gameDate,
    required super.scheduledAt,
    required super.stadium,
    required super.homeTeamCode,
    required super.homeTeamName,
    required super.awayTeamCode,
    required super.awayTeamName,
    required super.homeScore,
    required super.awayScore,
    required super.homeStarterPitcher,
    required super.awayStarterPitcher,
    required super.currentInning,
    required super.status,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      seasonYear: json['seasonYear'] as int,
      gameDate: json['gameDate'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      stadium: json['stadium'] as String?,
      homeTeamCode: json['homeTeamCode'] as String,
      homeTeamName: json['homeTeamName'] as String,
      awayTeamCode: json['awayTeamCode'] as String,
      awayTeamName: json['awayTeamName'] as String,
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      homeStarterPitcher: json['homeStarterPitcher'] as String?,
      awayStarterPitcher: json['awayStarterPitcher'] as String?,
      currentInning: json['currentInning'] as String?,
      status: _statusFromJson(json['status'] as String),
    );
  }

  static GameStatus _statusFromJson(String value) {
    return switch (value) {
      'SCHEDULED' => GameStatus.scheduled,
      'IN_PROGRESS' => GameStatus.inProgress,
      'FINISHED' => GameStatus.finished,
      'CANCELLED' => GameStatus.cancelled,
      'POSTPONED' => GameStatus.postponed,
      _ => throw ArgumentError('Unknown GameStatus: $value'),
    };
  }

  /// go_router의 `extra`로 [Game] 인스턴스를 넘기면, Flutter DevTools/라우터
  /// 인스펙터가 라우트 상태를 표시하려고 이 값을 직렬화를 시도한다. `toJson()`이
  /// 없으면 `NoSuchMethodError`가 던져지는데, 릴리즈 빌드는 그걸 지켜보는
  /// 디버거가 없어 무시되지만 IDE 디버거가 "예외 발생 시 중단"으로 붙어있으면
  /// 그 순간 전체 isolate가 멈춰 ANR로 이어진다.
  Map<String, dynamic> toJson() => {
    'id': id,
    'seasonYear': seasonYear,
    'gameDate': gameDate,
    'scheduledAt': scheduledAt.toIso8601String(),
    'stadium': stadium,
    'homeTeamCode': homeTeamCode,
    'homeTeamName': homeTeamName,
    'awayTeamCode': awayTeamCode,
    'awayTeamName': awayTeamName,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'homeStarterPitcher': homeStarterPitcher,
    'awayStarterPitcher': awayStarterPitcher,
    'currentInning': currentInning,
    'status': _statusToJson(status),
  };

  static String _statusToJson(GameStatus status) {
    return switch (status) {
      GameStatus.scheduled => 'SCHEDULED',
      GameStatus.inProgress => 'IN_PROGRESS',
      GameStatus.finished => 'FINISHED',
      GameStatus.cancelled => 'CANCELLED',
      GameStatus.postponed => 'POSTPONED',
    };
  }
}
