import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/features/attendance/data/models/attendance_record_model.dart';
import 'package:jikgwan/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/attendance/presentation/screens/my_attendance_screen.dart';
import 'package:jikgwan/features/home/presentation/widgets/my_attendance_section.dart';

import '../attendance_test_helpers.dart';

final _routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const Scaffold(body: MyAttendanceSection()),
  ),
  GoRoute(
    path: MyAttendanceScreen.routePath,
    name: MyAttendanceScreen.routeName,
    builder: (context, state) => const Text('my attendance'),
  ),
];

void main() {
  testWidgets('invites the first record when empty', (tester) async {
    final harness = AttendanceHarness();
    await harness.pump(tester, routes: _routes);

    expect(find.text('나의 직관'), findsOneWidget);
    expect(find.text('직관 0경기'), findsOneWidget);
    expect(find.text('다녀온 경기를 기록해 보세요'), findsOneWidget);

    await tester.tap(find.text('전체 보기'));
    await tester.pumpAndSettle();
    expect(find.text('my attendance'), findsOneWidget);
  });

  testWidgets('shows the count and the last attendance', (tester) async {
    final record = AttendanceRecord.create(
      id: 'a',
      game: attendanceGame('20261126OBLG0'),
      source: AttendanceRecordSource.summary,
      now: DateTime.utc(2026, 11, 26),
    );
    final harness = AttendanceHarness(
      initialPrefs: {
        AttendanceRepositoryImpl.storageKey: jsonEncode({
          'schemaVersion': 1,
          'records': [AttendanceRecordModel.fromEntity(record).toJson()],
        }),
      },
    );
    await harness.pump(tester, routes: _routes);

    expect(find.text('직관 1경기'), findsOneWidget);
    expect(find.text('마지막 직관 11.26 (목) 잠실 · LG 5:3 두산'), findsOneWidget);

    await tester.tap(find.text('직관 1경기'));
    await tester.pumpAndSettle();
    expect(find.text('my attendance'), findsOneWidget);
  });
}
