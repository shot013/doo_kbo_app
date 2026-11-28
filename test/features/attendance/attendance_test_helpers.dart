import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/core/storage/shared_preferences_provider.dart';
import 'package:jikgwan/features/attendance/data/datasources/attendance_analytics.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_source.dart';
import 'package:jikgwan/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/data/models/game_model.dart';
import 'package:jikgwan/features/game/data/models/game_result_model.dart';
import 'package:jikgwan/features/game/domain/entities/game_status.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테스트의 "지금". 오늘은 2026-11-28 (토).
final testNow = DateTime(2026, 11, 28, 12);

class FakeNetworkInfo implements NetworkInfo {
  const FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

class FakeAttendanceAnalytics implements AttendanceAnalytics {
  final events = <String>[];

  @override
  Future<void> logCheck(String gameId, AttendanceSource source) async =>
      events.add('check:$gameId:${source.value}');

  @override
  Future<void> logUncheck(String gameId, AttendanceSource source) async =>
      events.add('uncheck:$gameId:${source.value}');
}

/// 날짜별 경기 목록과 최근 경기 결과를 정해 두는 데이터 소스.
class FakeGameDataSource extends GameDummyDataSource {
  FakeGameDataSource({this.gamesByDate = const {}, this.results = const []});

  final Map<String, List<GameModel>> gamesByDate;
  final List<GameResultModel> results;
  final requestedDates = <String?>[];

  @override
  Future<List<GameModel>> getGames({int? seasonYear, String? gameDate}) async {
    requestedDates.add(gameDate);
    return gamesByDate[gameDate] ?? const [];
  }

  @override
  Future<List<GameResultModel>> getRecentGameResults({String? date}) async =>
      date == null
      ? results
      : results.where((result) => result.gameDate == date).toList();
}

GameModel testGame(
  String id, {
  String date = '2026-11-26',
  String home = 'LG',
  String homeName = 'LG 트윈스',
  String away = 'OB',
  String awayName = '두산 베어스',
  int? homeScore = 5,
  int? awayScore = 3,
  String? stadium = '잠실',
  GameStatus status = GameStatus.finished,
}) => GameModel(
  id: id,
  seasonYear: int.parse(date.substring(0, 4)),
  gameDate: date,
  scheduledAt: DateTime.parse('${date}T18:30:00'),
  stadium: stadium,
  homeTeamCode: home,
  homeTeamName: homeName,
  awayTeamCode: away,
  awayTeamName: awayName,
  homeScore: homeScore,
  awayScore: awayScore,
  homeStarterPitcher: null,
  awayStarterPitcher: null,
  currentInning: null,
  status: status,
);

GameResultModel testResult(
  String id, {
  String date = '2026-11-26',
  String home = 'LG',
  String homeName = 'LG 트윈스',
  String away = 'OB',
  String awayName = '두산 베어스',
  int homeScore = 5,
  int awayScore = 3,
  String? stadium = '잠실',
}) => GameResultModel(
  gameId: id,
  gameDate: date,
  stadium: stadium,
  homeTeamCode: home,
  homeTeamName: homeName,
  awayTeamCode: away,
  awayTeamName: awayName,
  homeScore: homeScore,
  awayScore: awayScore,
  bestPerformer: null,
  pitchers: const [],
);

AttendanceGame attendanceGame(
  String id, {
  String date = '2026-11-26',
  String home = 'LG',
  String away = 'OB',
  int? homeScore = 5,
  int? awayScore = 3,
  String? stadium = '잠실',
  GameStatus status = GameStatus.finished,
}) => AttendanceGame(
  gameId: id,
  seasonYear: int.parse(date.substring(0, 4)),
  gameDate: date,
  stadium: stadium,
  homeTeamCode: home,
  awayTeamCode: away,
  homeScore: homeScore,
  awayScore: awayScore,
  status: status,
);

/// 직관 기능 화면을 띄우는 공통 설정.
class AttendanceHarness {
  AttendanceHarness({FakeGameDataSource? games, this.initialPrefs = const {}})
    : games = games ?? FakeGameDataSource();

  final FakeGameDataSource games;
  final Map<String, Object> initialPrefs;
  final analytics = FakeAttendanceAnalytics();
  late SharedPreferences prefs;
  late ProviderContainer container;
  var _nextId = 0;

  Future<void> pump(
    WidgetTester tester, {
    required List<RouteBase> routes,
    String initialLocation = '/',
    List<Override> overrides = const [],
  }) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(initialPrefs);
    prefs = await SharedPreferences.getInstance();
    final router = GoRouter(initialLocation: initialLocation, routes: routes);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkInfoProvider.overrideWithValue(const FakeNetworkInfo()),
          gameRemoteDataSourceProvider.overrideWithValue(games),
          sharedPreferencesProvider.overrideWithValue(prefs),
          attendanceAnalyticsProvider.overrideWithValue(analytics),
          clockProvider.overrideWithValue(() => testNow),
          attendanceIdGeneratorProvider.overrideWithValue(
            () => 'id-${++_nextId}',
          ),
          ...overrides,
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
  }
}
