import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:jikgwan/features/attendance/presentation/screens/my_attendance_screen.dart';
import 'package:jikgwan/features/game_summary/data/datasources/game_summary_remote_data_source.dart';
import 'package:jikgwan/features/game_summary/data/models/game_summary_model.dart';
import 'package:jikgwan/features/game_summary/presentation/providers/game_summary_providers.dart';
import 'package:jikgwan/features/game_summary/presentation/screens/game_summary_screen.dart';

import '../attendance_test_helpers.dart';

List<RouteBase> _routes({String? date}) => [
  GoRoute(
    path: '/',
    builder: (context, state) =>
        GameSummaryScreen(date: date, initialGameId: '20261126OBLG0'),
  ),
  GoRoute(
    path: MyAttendanceScreen.routePath,
    name: MyAttendanceScreen.routeName,
    builder: (context, state) => const Text('my attendance'),
  ),
];

/// 요약 본문은 이 테스트의 관심사가 아니므로 404로 둔다.
class _NoSummaryDataSource implements GameSummaryRemoteDataSource {
  const _NoSummaryDataSource();

  @override
  Future<GameSummaryModel> getGameSummary(String gameId) async =>
      throw const NotFoundException();
}

final _summaryOverrides = [
  gameSummaryRemoteDataSourceProvider.overrideWithValue(
    const _NoSummaryDataSource(),
  ),
];

final _games = FakeGameDataSource(
  results: [
    testResult('20261126OBLG0'),
    testResult(
      '20261125SSHT0',
      date: '2026-11-25',
      home: 'HT',
      homeName: 'KIA 타이거즈',
      away: 'SS',
      awayName: '삼성 라이온즈',
    ),
  ],
);

void main() {
  testWidgets('checks the game from the summary and undoes it', (tester) async {
    final harness = AttendanceHarness(games: _games);
    await harness.pump(tester, routes: _routes(), overrides: _summaryOverrides);

    await tester.tap(find.text('이 경기 직관했어요'));
    await tester.pumpAndSettle();

    expect(find.text('직관한 경기예요'), findsOneWidget);
    expect(find.text('나의 직관에 추가했어요'), findsOneWidget);
    final record = harness.container
        .read(attendanceRecordsProvider)
        .records
        .single;
    expect(record.gameId, '20261126OBLG0');
    expect(record.source, AttendanceRecordSource.summary);
    expect(record.matchupText, 'LG 5:3 두산');

    await tester.tap(find.text('직관한 경기예요'));
    await tester.pumpAndSettle();
    expect(find.text('나의 직관에서 뺐어요'), findsOneWidget);
    expect(find.text('이 경기 직관했어요'), findsOneWidget);

    await tester.tap(find.text('되돌리기'));
    await tester.pumpAndSettle();
    expect(find.text('직관한 경기예요'), findsOneWidget);
    expect(
      harness.container.read(attendanceRecordsProvider).allRecords.single.id,
      record.id,
    );
    expect(harness.analytics.events, [
      'check:20261126OBLG0:summary',
      'uncheck:20261126OBLG0:summary',
      'check:20261126OBLG0:summary',
    ]);
  });

  testWidgets('the added snackbar opens my attendance', (tester) async {
    final harness = AttendanceHarness(games: _games);
    await harness.pump(tester, routes: _routes(), overrides: _summaryOverrides);

    await tester.tap(find.text('이 경기 직관했어요'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('보기'));
    await tester.pumpAndSettle();

    expect(find.text('my attendance'), findsOneWidget);
  });

  testWidgets('opens on a given date from my attendance', (tester) async {
    final harness = AttendanceHarness(games: _games);
    await harness.pump(
      tester,
      routes: _routes(date: '2026-11-25'),
      overrides: _summaryOverrides,
    );

    expect(find.text('2026-11-25 (수) · 1경기'), findsOneWidget);
    expect(find.text('KIA'), findsWidgets);
  });

  testWidgets('says so when the date has no finished game', (tester) async {
    final harness = AttendanceHarness(games: _games);
    await harness.pump(
      tester,
      routes: _routes(date: '2026-11-20'),
      overrides: _summaryOverrides,
    );

    expect(find.text('이 날 종료된 경기가 없습니다'), findsOneWidget);
  });
}
