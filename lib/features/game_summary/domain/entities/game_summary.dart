import 'package:equatable/equatable.dart';

import 'line_score.dart';
import 'pinch_hitter.dart';
import 'pitcher_appearance.dart';
import 'scoring_play.dart';

/// 경기 요약 (`GET /game-summaries/{gameId}`). 경기 칩과 점수 카드는 이
/// 데이터가 아니라 기존 최근 경기 결과(`GameResult`)로 그린다.
class GameSummary extends Equatable {
  const GameSummary({
    required this.gameId,
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.lineScore,
    required this.scoringPlays,
    required this.awayPitchers,
    required this.homePitchers,
    required this.awayPinchHitterSummary,
    required this.homePinchHitterSummary,
    required this.pinchHitterAppearances,
  });

  final String gameId;
  final String homeTeamCode;
  final String awayTeamCode;
  final LineScore lineScore;
  final List<ScoringPlay> scoringPlays;

  /// 등판 순서대로.
  final List<PitcherAppearance> awayPitchers;
  final List<PitcherAppearance> homePitchers;

  final PinchHitterSummary awayPinchHitterSummary;
  final PinchHitterSummary homePinchHitterSummary;

  /// 기용 순서대로. 두 팀 모두 없으면 빈 목록.
  final List<PinchHitterAppearance> pinchHitterAppearances;

  /// 아웃카운트 비율 막대의 전체 길이(이닝 수 × 3).
  int get totalOutsSlots => lineScore.inningCount * 3;

  List<PitcherAppearance> get _allPitchers => [
    ...awayPitchers,
    ...homePitchers,
  ];

  /// 출처에 투구 수가 하나도 없으면 투구 열을 숨긴다.
  bool get showsPitchCount => _allPitchers.any((p) => p.pitchCount != null);

  /// 출처에 실점이 하나도 없으면 실점 열을 숨긴다.
  bool get showsRuns => _allPitchers.any((p) => p.runs != null);

  /// 두 팀 중 한 팀이라도 대타 성적이 있는지.
  bool get hasPinchHitterStats =>
      awayPinchHitterSummary.count > 0 || homePinchHitterSummary.count > 0;

  /// 두 팀 모두 대타가 없으면 `대타 기용이 없었습니다.`를 보인다.
  bool get hasPinchHitters =>
      pinchHitterAppearances.isNotEmpty || hasPinchHitterStats;

  /// 문자중계를 아직 수집하지 못해 이닝 점수와 투수 기록만 있는 상태
  /// (KAN-8 v2, 정책서 5.8). 득점 장면과 대타 자리에 수집 중 문구를 보인다.
  ///
  /// 서버는 이때 득점 장면·대타 기용을 빈 목록으로, 구원 투수 등판 시점을
  /// null로 준다. 점수도 구원 투수도 없는 경기는 원래 보일 장면이 없으므로
  /// 수집 중으로 보지 않는다.
  bool get isDetailPending {
    final relievers = _allPitchers.where((p) => !p.isStarter);
    final scored = lineScore.away.runs + lineScore.home.runs > 0;
    return scoringPlays.isEmpty &&
        pinchHitterAppearances.isEmpty &&
        relievers.every((p) => p.entry == null) &&
        (scored || relievers.isNotEmpty);
  }

  @override
  List<Object?> get props => [
    gameId,
    homeTeamCode,
    awayTeamCode,
    lineScore,
    scoringPlays,
    awayPitchers,
    homePitchers,
    awayPinchHitterSummary,
    homePinchHitterSummary,
    pinchHitterAppearances,
  ];
}
