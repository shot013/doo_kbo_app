import 'package:equatable/equatable.dart';

import '../../../../core/constants/kbo_teams.dart';
import '../../../../core/utils/date_label.dart';
import '../../../../core/utils/team_name.dart';
import '../../../game/domain/entities/game.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../../game/domain/entities/game_status.dart';

/// 목록 행 오른쪽에 붙는 배지 (정책서 5.9).
enum AttendanceBadge {
  win('승'),
  loss('패'),
  draw('무'),
  beforeGame('경기 전'),
  inGame('경기 중'),
  cancelled('취소'),
  postponed('연기');

  const AttendanceBadge(this.label);

  final String label;

  /// 원형 배지(승·패·무)인지, 글자 배지인지.
  bool get isResult => this == win || this == loss || this == draw;
}

/// 기록을 처음 만든 화면 (정책서 6.3 `source`).
enum AttendanceRecordSource {
  summary('summary'),
  addScreen('add_screen');

  const AttendanceRecordSource(this.value);

  final String value;
}

/// 직관 체크에 쓰는 경기 정보. 오늘의 경기·경기 추가(`Game`)와 경기 요약
/// (`GameResult`) 어느 쪽에서 체크해도 같은 모양으로 맞춘다.
class AttendanceGame extends Equatable {
  const AttendanceGame({
    required this.gameId,
    required this.seasonYear,
    required this.gameDate,
    required this.stadium,
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.homeScore,
    required this.awayScore,
    required this.status,
  });

  factory AttendanceGame.fromGame(Game game) => AttendanceGame(
    gameId: game.id,
    seasonYear: game.seasonYear,
    gameDate: game.gameDate,
    stadium: game.stadium,
    homeTeamCode: game.homeTeamCode,
    awayTeamCode: game.awayTeamCode,
    homeScore: game.homeScore,
    awayScore: game.awayScore,
    status: game.status,
  );

  factory AttendanceGame.fromGameResult(GameResult result) => AttendanceGame(
    gameId: result.gameId,
    seasonYear:
        int.tryParse(result.gameDate.split('-').first) ?? DateTime.now().year,
    gameDate: result.gameDate,
    stadium: result.stadium,
    homeTeamCode: result.homeTeamCode,
    awayTeamCode: result.awayTeamCode,
    homeScore: result.homeScore,
    awayScore: result.awayScore,
    status: GameStatus.finished,
  );

  final String gameId;
  final int seasonYear;

  /// `YYYY-MM-DD` (한국 날짜)
  final String gameDate;
  final String? stadium;
  final String homeTeamCode;
  final String awayTeamCode;
  final int? homeScore;
  final int? awayScore;
  final GameStatus status;

  @override
  List<Object?> get props => [
    gameId,
    seasonYear,
    gameDate,
    stadium,
    homeTeamCode,
    awayTeamCode,
    homeScore,
    awayScore,
    status,
  ];
}

/// 직관한 경기 하나 (정책서 5.9, 6.3 직관 기록 저장 형식).
///
/// 나중에 서버 DB로 그대로 옮길 수 있게 [id]는 앱이 만든 UUID v4이고, 해제는
/// [deletedAt]을 채우는 소프트 삭제다. 되돌리기·재체크는 같은 [id]를 되살린다.
/// 점수·상태([homeScore], [awayScore], [gameStatus])는 화면용 캐시다.
class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.gameId,
    required this.seasonYear,
    required this.gameDate,
    required this.stadium,
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.homeScore,
    required this.awayScore,
    required this.gameStatus,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  /// 처음 체크한 기록.
  factory AttendanceRecord.create({
    required String id,
    required AttendanceGame game,
    required AttendanceRecordSource source,
    required DateTime now,
  }) {
    return AttendanceRecord(
      id: id,
      gameId: game.gameId,
      seasonYear: game.seasonYear,
      gameDate: game.gameDate,
      stadium: game.stadium,
      homeTeamCode: game.homeTeamCode,
      awayTeamCode: game.awayTeamCode,
      homeScore: game.homeScore,
      awayScore: game.awayScore,
      gameStatus: game.status,
      source: source,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  final String id;
  final String gameId;
  final int seasonYear;

  /// `YYYY-MM-DD` (한국 날짜)
  final String gameDate;
  final String? stadium;
  final String homeTeamCode;
  final String awayTeamCode;
  final int? homeScore;
  final int? awayScore;
  final GameStatus gameStatus;
  final AttendanceRecordSource source;
  final DateTime createdAt;

  /// 사용자가 바꿀 때(체크·해제·되돌리기)만 바뀐다. 점수 갱신 때는 그대로.
  final DateTime updatedAt;

  /// 해제·삭제한 시각. null이면 살아 있는 기록.
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// 저장된 경기 정보. 되돌리기에 쓴다.
  AttendanceGame get game => AttendanceGame(
    gameId: gameId,
    seasonYear: seasonYear,
    gameDate: gameDate,
    stadium: stadium,
    homeTeamCode: homeTeamCode,
    awayTeamCode: awayTeamCode,
    homeScore: homeScore,
    awayScore: awayScore,
    status: gameStatus,
  );

  String get homeTeamVisibleName => _visibleName(homeTeamCode);
  String get awayTeamVisibleName => _visibleName(awayTeamCode);

  static String _visibleName(String code) {
    for (final team in kKboTeams) {
      if (team.code == code) return shortTeamName(team.name);
    }
    return code;
  }

  bool get _hasScore =>
      gameStatus == GameStatus.finished &&
      homeScore != null &&
      awayScore != null;

  /// 열 때 다시 받아 점수·상태를 갱신할 경기 (경기 전·경기 중).
  bool get needsRefresh =>
      !isDeleted &&
      (gameStatus == GameStatus.scheduled ||
          gameStatus == GameStatus.inProgress);

  /// 예: `LG 5:3 두산`. 끝나지 않았거나 취소된 경기는 `LG vs 두산`.
  String get matchupText {
    final score = _hasScore ? '$homeScore:$awayScore' : 'vs';
    return '$homeTeamVisibleName $score $awayTeamVisibleName';
  }

  /// 예: `11.26`
  String get monthDayText => monthDayLabel(gameDate);

  /// 예: `목`
  String get weekdayText => koreanWeekday(gameDate);

  /// HOME 카드 둘째 줄. 예: `마지막 직관 11.26 (목) 잠실 · LG 5:3 두산`
  String get lastAttendanceText {
    final place = stadium == null ? '' : ' $stadium';
    return '마지막 직관 $monthDayText ($weekdayText)$place · $matchupText';
  }

  /// 배지. 끝나지 않았거나 취소·연기된 경기는 상태를, 끝난 경기는 MY팀 경기일
  /// 때만 승·패·무를 보인다. MY팀이 없거나 MY팀 경기가 아니면 null.
  AttendanceBadge? badgeFor(String? favoriteTeamCode) {
    switch (gameStatus) {
      case GameStatus.scheduled:
        return AttendanceBadge.beforeGame;
      case GameStatus.inProgress:
        return AttendanceBadge.inGame;
      case GameStatus.cancelled:
        return AttendanceBadge.cancelled;
      case GameStatus.postponed:
        return AttendanceBadge.postponed;
      case GameStatus.finished:
        break;
    }
    if (!_hasScore || favoriteTeamCode == null) return null;
    final int mine;
    final int theirs;
    if (favoriteTeamCode == homeTeamCode) {
      (mine, theirs) = (homeScore!, awayScore!);
    } else if (favoriteTeamCode == awayTeamCode) {
      (mine, theirs) = (awayScore!, homeScore!);
    } else {
      return null;
    }
    if (mine > theirs) return AttendanceBadge.win;
    if (mine < theirs) return AttendanceBadge.loss;
    return AttendanceBadge.draw;
  }

  /// 해제(소프트 삭제).
  AttendanceRecord deleted(DateTime now) =>
      _copy(updatedAt: now, deletedAt: () => now);

  /// 되돌리기·재체크. 같은 id를 되살리고 경기 정보는 새로 받은 값으로 둔다.
  AttendanceRecord restored(AttendanceGame game, DateTime now) =>
      _withGame(game)._copy(updatedAt: now, deletedAt: () => null);

  /// 다시 받은 경기로 점수·상태 캐시만 갱신한다. [updatedAt]은 그대로.
  AttendanceRecord refreshed(AttendanceGame game) => _withGame(game);

  AttendanceRecord _withGame(AttendanceGame game) => AttendanceRecord(
    id: id,
    gameId: gameId,
    seasonYear: game.seasonYear,
    gameDate: game.gameDate,
    stadium: game.stadium ?? stadium,
    homeTeamCode: game.homeTeamCode,
    awayTeamCode: game.awayTeamCode,
    homeScore: game.homeScore,
    awayScore: game.awayScore,
    gameStatus: game.status,
    source: source,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );

  AttendanceRecord _copy({
    required DateTime updatedAt,
    required DateTime? Function() deletedAt,
  }) => AttendanceRecord(
    id: id,
    gameId: gameId,
    seasonYear: seasonYear,
    gameDate: gameDate,
    stadium: stadium,
    homeTeamCode: homeTeamCode,
    awayTeamCode: awayTeamCode,
    homeScore: homeScore,
    awayScore: awayScore,
    gameStatus: gameStatus,
    source: source,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt(),
  );

  @override
  List<Object?> get props => [
    id,
    gameId,
    seasonYear,
    gameDate,
    stadium,
    homeTeamCode,
    awayTeamCode,
    homeScore,
    awayScore,
    gameStatus,
    source,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

/// 직관 체크 가능 여부 (정책서 5.9). 오늘까지의 경기만, 취소·연기 경기는 안 된다.
/// 오늘 경기는 예정·진행 중이어도 된다. [today]는 `YYYY-MM-DD`.
bool canAttend({
  required String gameDate,
  required GameStatus status,
  required String today,
}) {
  if (status == GameStatus.cancelled || status == GameStatus.postponed) {
    return false;
  }
  return gameDate.compareTo(today) <= 0;
}
