import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/features/attendance/data/models/attendance_record_model.dart';
import 'package:jikgwan/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:jikgwan/features/attendance/presentation/screens/add_attendance_screen.dart';
import 'package:jikgwan/features/attendance/presentation/screens/my_attendance_screen.dart';
import 'package:jikgwan/features/game/domain/entities/game_status.dart';
import 'package:jikgwan/features/game_summary/presentation/screens/game_summary_screen.dart';

import '../attendance_test_helpers.dart';

final _routes = [
  GoRoute(
    path: MyAttendanceScreen.routePath,
    name: MyAttendanceScreen.routeName,
    builder: (context, state) => const MyAttendanceScreen(),
    routes: [
      GoRoute(
        path: AddAttendanceScreen.routePath,
        name: AddAttendanceScreen.routeName,
        builder: (context, state) => const Text('add screen'),
      ),
    ],
  ),
  GoRoute(
    path: GameSummaryScreen.routePath,
    name: GameSummaryScreen.routeName,
    builder: (context, state) => Text(
      'summary:${state.uri.queryParameters['date']}:'
      '${state.uri.queryParameters['gameId']}',
    ),
  ),
];

Map<String, Object> _stored(List<AttendanceRecord> records) => {
  AttendanceRepositoryImpl.storageKey: jsonEncode({
    'schemaVersion': 1,
    'records': [
      for (final record in records)
        AttendanceRecordModel.fromEntity(record).toJson(),
    ],
  }),
};

AttendanceRecord _record(String id, AttendanceGame game) =>
    AttendanceRecord.create(
      id: id,
      game: game,
      source: AttendanceRecordSource.summary,
      now: DateTime.utc(2026, 11, 26, 12),
    );

void main() {
  testWidgets('shows the empty state and opens the add screen', (tester) async {
    final harness = AttendanceHarness();
    await harness.pump(
      tester,
      routes: _routes,
      initialLocation: MyAttendanceScreen.routePath,
    );

    expect(find.text('아직 직관 기록이 없어요'), findsOneWidget);
    await tester.tap(find.text('경기 추가'));
    await tester.pumpAndSettle();

    expect(find.text('add screen'), findsOneWidget);
  });

  testWidgets('lists records by season with the favorite team badge', (
    tester,
  ) async {
    final harness = AttendanceHarness(
      initialPrefs: {
        'favorite_team_code': 'OB',
        ..._stored([
          _record('a', attendanceGame('20261126OBLG0')),
          _record(
            'b',
            attendanceGame('20250901OBLG0', date: '2025-09-01', homeScore: 1),
          ),
        ]),
      },
    );
    await harness.pump(
      tester,
      routes: _routes,
      initialLocation: MyAttendanceScreen.routePath,
    );

    expect(find.text('2경기'), findsOneWidget);
    expect(find.text('2026 시즌'), findsOneWidget);
    expect(find.text('2025 시즌'), findsOneWidget);
    expect(find.text('LG 5:3 두산'), findsOneWidget);
    // 두산 팬: 3:5 패, 3:1 승.
    expect(find.text('패'), findsOneWidget);
    expect(find.text('승'), findsOneWidget);
    expect(find.text('기록은 이 휴대폰에만 저장돼요. 앱을 지우면 함께 지워져요.'), findsOneWidget);

    await tester.tap(find.text('LG 5:3 두산'));
    await tester.pumpAndSettle();
    expect(find.text('summary:2026-11-26:20261126OBLG0'), findsOneWidget);
  });

  testWidgets('swipe removes a record and undo revives the same id', (
    tester,
  ) async {
    final harness = AttendanceHarness(
      initialPrefs: _stored([_record('a', attendanceGame('20261126OBLG0'))]),
    );
    await harness.pump(
      tester,
      routes: _routes,
      initialLocation: MyAttendanceScreen.routePath,
    );

    await tester.drag(find.text('LG 5:3 두산'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('나의 직관에서 뺐어요'), findsOneWidget);
    expect(find.text('아직 직관 기록이 없어요'), findsOneWidget);

    await tester.tap(find.text('되돌리기'));
    await tester.pumpAndSettle();

    expect(find.text('LG 5:3 두산'), findsOneWidget);
    final list = harness.container.read(attendanceRecordsProvider);
    expect(list.allRecords.single.id, 'a');
    expect(list.allRecords.single.deletedAt, isNull);
    expect(harness.analytics.events, [
      'uncheck:20261126OBLG0:list',
      'check:20261126OBLG0:list',
    ]);
  });

  testWidgets('refreshes unfinished games when opened', (tester) async {
    final games = FakeGameDataSource(
      gamesByDate: {
        '2026-11-28': [
          testGame('20261128OBLG0', date: '2026-11-28', homeScore: 7),
        ],
      },
    );
    final harness = AttendanceHarness(
      games: games,
      initialPrefs: _stored([
        _record(
          'a',
          attendanceGame(
            '20261128OBLG0',
            date: '2026-11-28',
            homeScore: null,
            awayScore: null,
            status: GameStatus.scheduled,
          ),
        ),
        _record('b', attendanceGame('20261126OBLG0')),
      ]),
    );
    await harness.pump(
      tester,
      routes: _routes,
      initialLocation: MyAttendanceScreen.routePath,
    );

    // 끝난 경기(11-26)는 다시 받지 않는다.
    expect(games.requestedDates, ['2026-11-28']);
    expect(find.text('LG 7:3 두산'), findsOneWidget);
    final refreshed = harness.container
        .read(attendanceRecordsProvider)
        .records
        .first;
    expect(refreshed.updatedAt, DateTime.utc(2026, 11, 26, 12));
  });
}
