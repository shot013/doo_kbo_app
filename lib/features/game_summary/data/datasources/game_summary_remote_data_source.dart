import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../game/domain/entities/pitcher_decision_type.dart';
import '../../domain/entities/inning_half.dart';
import '../../domain/entities/pitcher_appearance.dart';
import '../models/game_summary_model.dart';
import '../models/line_score_model.dart';
import '../models/pinch_hitter_model.dart';
import '../models/pitcher_appearance_model.dart';
import '../models/scoring_play_model.dart';

abstract interface class GameSummaryRemoteDataSource {
  /// 요약 데이터가 아직 없으면 [NotFoundException].
  Future<GameSummaryModel> getGameSummary(String gameId);
}

class GameSummaryRemoteDataSourceImpl implements GameSummaryRemoteDataSource {
  const GameSummaryRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<GameSummaryModel> getGameSummary(String gameId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/game-summaries/${Uri.encodeComponent(gameId)}',
      );
      return GameSummaryModel.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException();
      }
      throw const ServerException();
    }
  }
}

/// 서버 API가 나오기 전에 화면을 만들고 테스트하려고 둔 더미 구현체입니다.
/// 디자인(`figma-sample/game-summary-workflow/`)의 예시 경기
/// 2026-11-26 LG 5:3 두산만 요약이 있고, 다른 경기는 404로 응답합니다.
class GameSummaryDummyDataSource implements GameSummaryRemoteDataSource {
  const GameSummaryDummyDataSource({
    this.delay = const Duration(milliseconds: 300),
  });

  final Duration delay;

  static const exampleGameId = '20261126OBLG0';

  @override
  Future<GameSummaryModel> getGameSummary(String gameId) async {
    await Future<void>.delayed(delay);
    if (gameId != exampleGameId) {
      throw const NotFoundException();
    }
    return dummyGameSummary;
  }
}

const dummyGameSummary = GameSummaryModel(
  gameId: GameSummaryDummyDataSource.exampleGameId,
  homeTeamCode: 'LG',
  awayTeamCode: 'OB',
  lineScore: LineScoreModel(
    inningCount: 9,
    away: TeamLineScoreModel(
      teamCode: 'OB',
      innings: [0, 1, 0, 0, 2, 0, 0, 0, 0],
      runs: 3,
      hits: 8,
      errors: 1,
      walks: 3,
    ),
    home: TeamLineScoreModel(
      teamCode: 'LG',
      innings: [1, 0, 0, 0, 0, 3, 0, 1, null],
      runs: 5,
      hits: 10,
      errors: 0,
      walks: 4,
    ),
  ),
  scoringPlays: [
    ScoringPlayModel(
      inning: 1,
      half: InningHalf.bottom,
      teamCode: 'LG',
      description: '구유격 적시타',
      homeScore: 1,
      awayScore: 0,
      isReversal: false,
      isTying: false,
    ),
    ScoringPlayModel(
      inning: 2,
      half: InningHalf.top,
      teamCode: 'OB',
      description: '최유격 솔로 홈런',
      homeScore: 1,
      awayScore: 1,
      isReversal: false,
      isTying: true,
    ),
    ScoringPlayModel(
      inning: 5,
      half: InningHalf.top,
      teamCode: 'OB',
      description: '오른손 2타점 2루타',
      homeScore: 1,
      awayScore: 3,
      isReversal: false,
      isTying: false,
    ),
    ScoringPlayModel(
      inning: 6,
      half: InningHalf.bottom,
      teamCode: 'LG',
      description: '정내야 3점 홈런',
      homeScore: 4,
      awayScore: 3,
      isReversal: true,
      isTying: false,
    ),
    ScoringPlayModel(
      inning: 8,
      half: InningHalf.bottom,
      teamCode: 'LG',
      description: '대타 표중견 1타점 2루타',
      homeScore: 5,
      awayScore: 3,
      isReversal: false,
      isTying: false,
    ),
  ],
  awayPitchers: [
    PitcherAppearanceModel(
      playerId: 1001,
      playerName: '정두산',
      role: PitcherRole.starter,
      entry: null,
      outs: 16,
      pitchCount: 96,
      runs: 4,
      decision: PitcherDecisionType.loss,
    ),
    PitcherAppearanceModel(
      playerId: 1002,
      playerName: '이불펜',
      role: PitcherRole.reliever,
      entry: PitcherEntryModel(
        inning: 6,
        half: InningHalf.bottom,
        outs: 1,
        runners: [1],
        atInningStart: false,
      ),
      outs: 5,
      pitchCount: 22,
      runs: 0,
      decision: null,
    ),
    PitcherAppearanceModel(
      playerId: 1003,
      playerName: '홍좌완',
      role: PitcherRole.reliever,
      entry: PitcherEntryModel(
        inning: 8,
        half: InningHalf.bottom,
        outs: 0,
        runners: [],
        atInningStart: true,
      ),
      outs: 3,
      pitchCount: 18,
      runs: 1,
      decision: null,
    ),
  ],
  homePitchers: [
    PitcherAppearanceModel(
      playerId: 2101,
      playerName: '남선발',
      role: PitcherRole.starter,
      entry: null,
      outs: 15,
      pitchCount: 88,
      runs: 3,
      decision: null,
    ),
    PitcherAppearanceModel(
      playerId: 2102,
      playerName: '김직관',
      role: PitcherRole.reliever,
      entry: PitcherEntryModel(
        inning: 6,
        half: InningHalf.top,
        outs: 0,
        runners: [],
        atInningStart: true,
      ),
      outs: 12,
      pitchCount: 51,
      runs: 0,
      decision: PitcherDecisionType.win,
    ),
  ],
  awayPinchHitterSummary: PinchHitterSummaryModel(
    teamCode: 'OB',
    count: 2,
    atBats: 2,
    hits: 0,
    rbi: 0,
  ),
  homePinchHitterSummary: PinchHitterSummaryModel(
    teamCode: 'LG',
    count: 1,
    atBats: 1,
    hits: 1,
    rbi: 1,
  ),
  pinchHitterAppearances: [
    PinchHitterAppearanceModel(
      inning: 7,
      half: InningHalf.top,
      teamCode: 'OB',
      playerId: 1101,
      playerName: '장대타',
      replacedPlayerId: 1102,
      replacedPlayerName: '민포수',
      pitcherId: 2102,
      pitcherName: '김직관',
      resultText: '삼진',
      isHit: false,
      rbi: 0,
    ),
    PinchHitterAppearanceModel(
      inning: 8,
      half: InningHalf.bottom,
      teamCode: 'LG',
      playerId: 2001,
      playerName: '표중견',
      replacedPlayerId: 2002,
      replacedPlayerName: '노우익',
      pitcherId: 1003,
      pitcherName: '홍좌완',
      resultText: '2루타',
      isHit: true,
      rbi: 1,
    ),
    PinchHitterAppearanceModel(
      inning: 9,
      half: InningHalf.top,
      teamCode: 'OB',
      playerId: 1103,
      playerName: '윤대주',
      replacedPlayerId: 1104,
      replacedPlayerName: '오른손',
      pitcherId: 2102,
      pitcherName: '김직관',
      resultText: '유격수 땅볼',
      isHit: false,
      rbi: 0,
    ),
  ],
);
