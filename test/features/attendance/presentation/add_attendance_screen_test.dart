import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/attendance/presentation/providers/attendance_providers.dart';
import 'package:jikgwan/features/attendance/presentation/screens/add_attendance_screen.dart';
import 'package:jikgwan/features/game/domain/entities/game_status.dart';

import '../attendance_test_helpers.dart';

final _routes = [
  GoRoute(path: '/', builder: (context, state) => const AddAttendanceScreen()),
];

void main() {
  testWidgets('defaults to the recent game date and toggles a game', (
    tester,
  ) async {
    final games = FakeGameDataSource(
      results: [testResult('20261126OBLG0')],
      gamesByDate: {
        '2026-11-26': [
          testGame('20261126OBLG0'),
          testGame(
            '20261126SSHT0',
            home: 'HT',
            homeName: 'KIA 타이거즈',
            away: 'SS',
            awayName: '삼성 라이온즈',
            homeScore: null,
            awayScore: null,
            stadium: '광주',
            status: GameStatus.cancelled,
          ),
        ],
      },
    );
    final harness = AttendanceHarness(games: games);
    await harness.pump(tester, routes: _routes);

    expect(find.text('2026-11-26 (목)'), findsOneWidget);
    expect(find.text('다녀온 경기를 눌러 추가하세요. 다시 누르면 빠져요.'), findsOneWidget);
    expect(find.text('잠실 · 경기 종료'), findsOneWidget);
    expect(find.text('광주 · 경기 취소'), findsOneWidget);
    expect(find.text('추가할 수 없음'), findsOneWidget);

    await tester.tap(find.text('LG 5:3 두산'));
    await tester.pumpAndSettle();

    final list = harness.container.read(attendanceRecordsProvider);
    expect(list.records.single.gameId, '20261126OBLG0');
    expect(list.records.single.source, AttendanceRecordSource.addScreen);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    // 취소된 경기는 눌러도 추가되지 않는다.
    await tester.tap(find.text('KIA vs 삼성'));
    await tester.pumpAndSettle();
    expect(harness.container.read(attendanceRecordsProvider).count, 1);

    await tester.tap(find.text('LG 5:3 두산'));
    await tester.pumpAndSettle();
    expect(harness.container.read(attendanceRecordsProvider).isEmpty, isTrue);
    expect(harness.analytics.events, [
      'check:20261126OBLG0:add_screen',
      'uncheck:20261126OBLG0:add_screen',
    ]);
  });

  testWidgets('moves between days but not past today', (tester) async {
    final harness = AttendanceHarness();
    await harness.pump(tester, routes: _routes);

    // 최근 경기 결과가 없으면 오늘.
    expect(find.text('2026-11-28 (토)'), findsOneWidget);
    expect(find.text('이 날은 경기가 없어요'), findsOneWidget);
    final next = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );
    expect(next.onPressed, isNull);

    await tester.tap(find.byTooltip('이전 날'));
    await tester.pumpAndSettle();
    expect(find.text('2026-11-27 (금)'), findsOneWidget);
  });

  testWidgets('picks a date from the calendar', (tester) async {
    final harness = AttendanceHarness();
    await harness.pump(tester, routes: _routes);

    await tester.tap(find.text('2026-11-28 (토)'));
    await tester.pumpAndSettle();

    expect(find.text('2026년 11월'), findsOneWidget);
    // 오늘 뒤의 날짜는 고를 수 없다.
    await tester.tap(find.text('29'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 11월'), findsOneWidget);

    await tester.tap(find.byTooltip('이전 달'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(find.text('2026-10-03 (토)'), findsOneWidget);
  });
}
