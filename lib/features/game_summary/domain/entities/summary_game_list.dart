import '../../../../core/utils/date_label.dart';
import '../../../game/domain/entities/game_result.dart';

/// 경기 요약 화면 상단의 최근 경기일 경기 칩 목록.
///
/// MY팀 경기가 있으면 맨 앞에 두고, 나머지는 서버 순서를 따른다 (정책서 5.8).
class SummaryGameList {
  SummaryGameList(
    List<GameResult> games, {
    String? favoriteTeamCode,
    this.isRecent = true,
  }) : games = [
         ...games.where((game) => _involves(game, favoriteTeamCode)),
         ...games.where((game) => !_involves(game, favoriteTeamCode)),
       ];

  final List<GameResult> games;

  /// 최근 경기일(HOME에서 열기)인지, 나의 직관에서 고른 날짜인지.
  final bool isRecent;

  bool get isEmpty => games.isEmpty;

  static bool _involves(GameResult game, String? teamCode) =>
      teamCode != null &&
      (game.homeTeamCode == teamCode || game.awayTeamCode == teamCode);

  /// [gameId]의 경기. 목록에 없으면 맨 앞 경기(MY팀 경기가 있으면 그 경기).
  GameResult? select(String? gameId) {
    if (games.isEmpty) return null;
    return games.firstWhere(
      (game) => game.gameId == gameId,
      orElse: () => games.first,
    );
  }

  /// 예: `최근 경기일 2026-11-26 (목) · 4경기`. 나의 직관에서 날짜를 정해
  /// 열었으면 `2026-11-26 (목) · 4경기` (정책서 5.8).
  String get dateLabel {
    if (games.isEmpty) return '';
    final label =
        '${dateWithWeekday(games.first.gameDate)} · ${games.length}경기';
    return isRecent ? '최근 경기일 $label' : label;
  }

  /// 예: `LG 5:3 두산`. 같은 날 같은 두 팀 경기가 둘이면(더블헤더) 끝에
  /// `(1)`, `(2)`를 붙인다.
  String chipLabel(GameResult game) {
    final label =
        '${game.homeTeamVisibleName} ${game.homeScore}:${game.awayScore} '
        '${game.awayTeamVisibleName}';
    final sameMatchup =
        games
            .where(
              (other) =>
                  other.homeTeamCode == game.homeTeamCode &&
                  other.awayTeamCode == game.awayTeamCode,
            )
            .toList()
          ..sort((a, b) => a.gameId.compareTo(b.gameId));
    if (sameMatchup.length < 2) return label;
    return '$label (${sameMatchup.indexOf(game) + 1})';
  }
}
