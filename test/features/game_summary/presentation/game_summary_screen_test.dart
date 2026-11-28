import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/core/error/failures.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/core/storage/shared_preferences_provider.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/data/models/game_result_model.dart';
import 'package:jikgwan/features/game/data/models/pitcher_decision_model.dart';
import 'package:jikgwan/features/game/domain/entities/pitcher_decision_type.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/game_summary/data/datasources/game_summary_remote_data_source.dart';
import 'package:jikgwan/features/game_summary/data/models/game_summary_model.dart';
import 'package:jikgwan/features/game_summary/domain/entities/pinch_hitter.dart';
import 'package:jikgwan/features/game_summary/domain/entities/pitcher_appearance.dart';
import 'package:jikgwan/features/game_summary/presentation/providers/game_summary_providers.dart';
import 'package:jikgwan/features/game_summary/presentation/screens/game_summary_screen.dart';
import 'package:jikgwan/features/game_summary/presentation/widgets/summary_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

GameResultModel _result(
  String gameId,
  String home,
  String homeName,
  int homeScore,
  int awayScore,
  String away,
  String awayName, {
  String? stadium,
  List<PitcherDecisionModel> pitchers = const [],
}) => GameResultModel(
  gameId: gameId,
  gameDate: '2026-11-26',
  stadium: stadium,
  homeTeamCode: home,
  homeTeamName: homeName,
  awayTeamCode: away,
  awayTeamName: awayName,
  homeScore: homeScore,
  awayScore: awayScore,
  bestPerformer: null,
  pitchers: pitchers,
);

PitcherDecisionModel _decision(
  PitcherDecisionType decision,
  String name,
  String team,
) => PitcherDecisionModel(
  decision: decision,
  playerName: name,
  teamCode: team,
  inningsPitched: null,
  earnedRuns: null,
  strikeoutsPitched: null,
  era: null,
);

/// 디자인 예시와 같은 2026-11-26 최근 경기 4개.
final _designGames = [
  _result(
    GameSummaryDummyDataSource.exampleGameId,
    'LG',
    'LG 트윈스',
    5,
    3,
    'OB',
    '두산 베어스',
    stadium: '잠실',
    pitchers: [
      _decision(PitcherDecisionType.win, '김직관', 'LG'),
      _decision(PitcherDecisionType.loss, '정두산', 'OB'),
    ],
  ),
  _result(
    '20261126SSHT0',
    'HT',
    'KIA 타이거즈',
    2,
    6,
    'SS',
    '삼성 라이온즈',
    stadium: '광주',
    pitchers: [
      _decision(PitcherDecisionType.loss, '한기아', 'HT'),
      _decision(PitcherDecisionType.win, '이사자', 'SS'),
    ],
  ),
  _result('20261126SKKT0', 'KT', 'kt wiz', 4, 1, 'SK', 'SSG 랜더스'),
  _result('20261126WOHH0', 'HH', '한화 이글스', 3, 7, 'WO', '키움 히어로즈'),
];

class _FakeGameDataSource extends GameDummyDataSource {
  const _FakeGameDataSource(this.results);

  final List<GameResultModel> results;

  @override
  Future<List<GameResultModel>> getRecentGameResults({String? date}) async =>
      results;
}

/// 요청 횟수를 세는 요약 데이터 소스 (404·오프라인 재시도 여부 확인용).
class _CountingSummaryDataSource implements GameSummaryRemoteDataSource {
  int calls = 0;

  @override
  Future<GameSummaryModel> getGameSummary(String gameId) {
    calls++;
    return const GameSummaryDummyDataSource(
      delay: Duration.zero,
    ).getGameSummary(gameId);
  }
}

/// 문자중계 수집 전 응답: 득점 장면·대타 기용이 비어 있고 구원 투수 등판
/// 시점이 null (KAN-8 v2).
class _PendingSummaryDataSource implements GameSummaryRemoteDataSource {
  _PendingSummaryDataSource({this.withPinchHitterStats = false});

  /// 팀별 대타 성적은 박스스코어로 와 있는 경우.
  final bool withPinchHitterStats;

  @override
  Future<GameSummaryModel> getGameSummary(String gameId) async {
    PitcherAppearance withoutEntry(PitcherAppearance p) => PitcherAppearance(
      playerId: p.playerId,
      playerName: p.playerName,
      role: p.role,
      entry: null,
      outs: p.outs,
      pitchCount: p.pitchCount,
      runs: p.runs,
      decision: p.decision,
    );
    PinchHitterSummary none(String teamCode) => PinchHitterSummary(
      teamCode: teamCode,
      count: 0,
      atBats: 0,
      hits: 0,
      rbi: 0,
    );
    const source = dummyGameSummary;
    return GameSummaryModel(
      gameId: source.gameId,
      homeTeamCode: source.homeTeamCode,
      awayTeamCode: source.awayTeamCode,
      lineScore: source.lineScore,
      scoringPlays: const [],
      awayPitchers: source.awayPitchers.map(withoutEntry).toList(),
      homePitchers: source.homePitchers.map(withoutEntry).toList(),
      awayPinchHitterSummary: withPinchHitterStats
          ? source.awayPinchHitterSummary
          : none(source.awayTeamCode),
      homePinchHitterSummary: withPinchHitterStats
          ? source.homePinchHitterSummary
          : none(source.homeTeamCode),
      pinchHitterAppearances: const [],
    );
  }
}

Future<void> _pump(
  WidgetTester tester, {
  List<GameResultModel>? games,
  String? initialGameId,
  String? favoriteTeamCode,
  GameSummaryRemoteDataSource? summaryDataSource,
  double width = 800,
}) async {
  tester.view.physicalSize = Size(width, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'favorite_team_code': ?favoriteTeamCode,
  });
  final sharedPreferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
        gameRemoteDataSourceProvider.overrideWithValue(
          _FakeGameDataSource(games ?? _designGames),
        ),
        gameSummaryRemoteDataSourceProvider.overrideWithValue(
          summaryDataSource ??
              const GameSummaryDummyDataSource(delay: Duration.zero),
        ),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MaterialApp(home: GameSummaryScreen(initialGameId: initialGameId)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the first game with its runs by inning', (tester) async {
    await _pump(tester);

    expect(find.text('경기 요약'), findsOneWidget);
    expect(find.text('최근 경기일 2026-11-26 (목) · 4경기'), findsOneWidget);
    expect(find.text('LG 5:3 두산'), findsOneWidget);
    expect(find.text('KT 4:1 SSG'), findsOneWidget);
    expect(find.text('잠실 · 경기 종료'), findsOneWidget);
    expect(find.text('5 : 3'), findsOneWidget);
    expect(find.text('승 김직관'), findsOneWidget);
    expect(find.text('패 정두산'), findsOneWidget);

    expect(find.text('이닝별 득점 흐름'), findsOneWidget);
    // 하지 않은 9회말은 표기 없이 비운다.
    expect(find.text('X'), findsNothing);
    expect(find.text('득점 장면'), findsOneWidget);
    expect(find.text('정내야 3점 홈런 (역전)'), findsOneWidget);
    expect(find.text('최유격 솔로 홈런 (동점)'), findsOneWidget);
    expect(find.text('6회말'), findsOneWidget);
    expect(find.text('4:3'), findsOneWidget);
  });

  testWidgets('hides pitcher names that do not fit their bar', (tester) async {
    await _pump(tester, width: 320);

    await tester.tap(find.text('투수 교체'));
    await tester.pumpAndSettle();

    // 1이닝만 던진 홍좌완은 막대가 좁아 표에만, 정두산은 막대와 표 둘 다.
    expect(find.text('홍좌완'), findsOneWidget);
    expect(find.text('정두산'), findsNWidgets(2));
  });

  testWidgets('switches between the three toggles', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('투수 교체'));
    await tester.pumpAndSettle();

    expect(find.text('두산 투수'), findsOneWidget);
    expect(find.text('LG 투수'), findsOneWidget);
    expect(find.text('3명 등판'), findsOneWidget);
    expect(find.text('6회말 1사 1루'), findsOneWidget);
    expect(find.text('8회말 시작'), findsOneWidget);
    expect(find.text('선발 등판'), findsNWidgets(2));
    expect(find.text('5.1'), findsOneWidget);
    expect(find.text('승'), findsOneWidget);
    expect(find.text('패'), findsOneWidget);
    // 9회말을 하지 않아 두산 투수가 던지지 않은 칸.
    expect(find.text('—'), findsOneWidget);
    // 두산 2번·LG 1번 교체.
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'pitching-change-marker',
            ),
      ),
      findsNWidgets(3),
    );

    await tester.tap(find.text('대타'));
    await tester.pumpAndSettle();

    expect(find.text('LG · 대타 1명'), findsOneWidget);
    expect(find.text('1타수 1안타 1타점'), findsOneWidget);
    expect(find.text('두산 · 대타 2명'), findsOneWidget);
    expect(find.text('2타수 무안타'), findsOneWidget);
    expect(find.text('대타 표중견'), findsOneWidget);
    expect(find.text('노우익 대신 · vs 홍좌완'), findsOneWidget);
    expect(find.text('2루타 · 1타점'), findsOneWidget);
    expect(find.text('삼진'), findsOneWidget);
  });

  testWidgets(
    'shows the no-summary message without toggles and keeps the toggle',
    (tester) async {
      final dataSource = _CountingSummaryDataSource();
      await _pump(tester, summaryDataSource: dataSource);

      await tester.tap(find.text('대타'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KIA 2:6 삼성'));
      await tester.pumpAndSettle();

      expect(find.text('아직 이 경기의 요약 정보가 없습니다.'), findsOneWidget);
      expect(find.text('광주 · 경기 종료'), findsOneWidget);
      expect(find.text('패 한기아'), findsOneWidget);
      expect(find.text('투수 교체'), findsNothing);
      // 404는 재시도하지 않는다: LG 1회 + KIA 1회.
      expect(dataSource.calls, 2);

      await tester.tap(find.text('LG 5:3 두산'));
      await tester.pumpAndSettle();

      expect(find.text('대타 표중견'), findsOneWidget);
    },
  );

  testWidgets('shows the collecting message before play-by-play arrives', (
    tester,
  ) async {
    await _pump(tester, summaryDataSource: _PendingSummaryDataSource());

    expect(find.text('이닝별 득점 흐름'), findsOneWidget);
    expect(find.text('득점 장면'), findsOneWidget);
    expect(find.text(DetailPendingCard.message), findsOneWidget);

    await tester.tap(find.text('투수 교체'));
    await tester.pumpAndSettle();

    expect(find.text('두산 투수'), findsOneWidget);
    expect(find.text('6회말 1사 1루'), findsNothing);
    // 구원 투수 3명(이불펜, 홍좌완, 김직관)의 교체 시점.
    expect(find.text('-'), findsNWidgets(3));

    await tester.tap(find.text('대타'));
    await tester.pumpAndSettle();

    expect(find.text('대타 기용'), findsOneWidget);
    expect(find.text(DetailPendingCard.message), findsOneWidget);
    expect(find.text('대타 기용이 없었습니다.'), findsNothing);
    expect(find.text('LG · 대타 0명'), findsNothing);
  });

  testWidgets('shows only pinch hitter stats before play-by-play arrives', (
    tester,
  ) async {
    await _pump(
      tester,
      summaryDataSource: _PendingSummaryDataSource(withPinchHitterStats: true),
    );

    await tester.tap(find.text('대타'));
    await tester.pumpAndSettle();

    expect(find.text('LG · 대타 1명'), findsOneWidget);
    expect(find.text('대타 기용'), findsNothing);
    expect(find.text(DetailPendingCard.message), findsNothing);
  });

  testWidgets('puts the favorite team game first and selects it', (
    tester,
  ) async {
    await _pump(tester, favoriteTeamCode: 'SS');

    final chipLabels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(ListView).last,
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .toList();
    expect(chipLabels.first, 'KIA 2:6 삼성');
    expect(find.text('아직 이 경기의 요약 정보가 없습니다.'), findsOneWidget);
  });

  testWidgets('selects the game passed from a recent result card', (
    tester,
  ) async {
    await _pump(tester, initialGameId: '20261126SSHT0');

    expect(find.text('2 : 6'), findsOneWidget);
    expect(find.text('아직 이 경기의 요약 정보가 없습니다.'), findsOneWidget);
  });

  testWidgets('shows the empty message when no game has finished', (
    tester,
  ) async {
    await _pump(tester, games: const []);

    expect(find.text('최근 종료된 경기가 없습니다'), findsOneWidget);
  });

  test('retries only server errors, briefly', () {
    expect(gameSummaryRetry(0, const NotFoundFailure()), isNull);
    expect(gameSummaryRetry(0, const NetworkFailure()), isNull);
    expect(gameSummaryRetry(0, const ServerFailure()), isNotNull);
    expect(gameSummaryRetry(2, const ServerFailure()), isNull);
    expect(gameSummaryRetry(0, const ServerException()), isNotNull);
  });
}
