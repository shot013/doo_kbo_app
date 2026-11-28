import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_list.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/game/domain/entities/game_status.dart';

import '../attendance_test_helpers.dart';

void main() {
  final t1 = DateTime.utc(2026, 11, 26, 10);
  final t2 = DateTime.utc(2026, 11, 27, 10);
  final t3 = DateTime.utc(2026, 11, 28, 10);
  var ids = 0;
  String newId() => 'id-${++ids}';

  setUp(() => ids = 0);

  AttendanceList checked(List<AttendanceGame> games) {
    var list = AttendanceList(const []);
    for (final game in games) {
      list = list.check(
        game,
        source: AttendanceRecordSource.summary,
        now: t1,
        newId: newId,
      );
    }
    return list;
  }

  group('AttendanceList', () {
    test('check creates a record with a new id and the given source', () {
      final list = AttendanceList(const []).check(
        attendanceGame('g1'),
        source: AttendanceRecordSource.addScreen,
        now: t1,
        newId: newId,
      );

      final record = list.records.single;
      expect(record.id, 'id-1');
      expect(record.gameId, 'g1');
      expect(record.source, AttendanceRecordSource.addScreen);
      expect(record.createdAt, t1);
      expect(record.updatedAt, t1);
      expect(record.deletedAt, isNull);
      expect(list.contains('g1'), isTrue);
      expect(list.countText, '1경기');
    });

    test('check is a no-op for a game already checked', () {
      final list = checked([attendanceGame('g1')]);

      final again = list.check(
        attendanceGame('g1'),
        source: AttendanceRecordSource.summary,
        now: t2,
        newId: newId,
      );

      expect(again, list);
      expect(ids, 1);
    });

    test('uncheck soft-deletes and hides the record from the list', () {
      final list = checked([attendanceGame('g1')]).uncheck('g1', now: t2);

      expect(list.isEmpty, isTrue);
      expect(list.count, 0);
      expect(list.contains('g1'), isFalse);
      final stored = list.allRecords.single;
      expect(stored.deletedAt, t2);
      expect(stored.updatedAt, t2);
    });

    test('re-checking revives the same id instead of adding a record', () {
      final list = checked([attendanceGame('g1')])
          .uncheck('g1', now: t2)
          .check(
            attendanceGame('g1'),
            source: AttendanceRecordSource.addScreen,
            now: t3,
            newId: newId,
          );

      expect(list.allRecords, hasLength(1));
      final record = list.records.single;
      expect(record.id, 'id-1');
      expect(record.deletedAt, isNull);
      expect(record.createdAt, t1);
      expect(record.updatedAt, t3);
      // 처음 추가한 경로는 그대로 둔다.
      expect(record.source, AttendanceRecordSource.summary);
    });

    test('refresh updates the score cache but not updatedAt', () {
      final list = checked([
        attendanceGame(
          'g1',
          homeScore: null,
          awayScore: null,
          status: GameStatus.inProgress,
        ),
      ]);
      expect(list.records.single.needsRefresh, isTrue);

      final refreshed = list.refresh([attendanceGame('g1')]);

      final record = refreshed.records.single;
      expect(record.gameStatus, GameStatus.finished);
      expect(record.matchupText, 'LG 5:3 두산');
      expect(record.updatedAt, t1);
      expect(record.needsRefresh, isFalse);
    });

    test('refresh leaves deleted records untouched', () {
      final list = checked([
        attendanceGame('g1', status: GameStatus.scheduled),
      ]).uncheck('g1', now: t2);

      final refreshed = list.refresh([attendanceGame('g1')]);

      expect(refreshed, list);
    });

    test('sorts newest first and groups by season', () {
      final list = checked([
        attendanceGame('20250901LGOB0', date: '2025-09-01'),
        attendanceGame('20261126LGOB1', date: '2026-11-26'),
        attendanceGame('20261126LGOB2', date: '2026-11-26'),
        attendanceGame('20260401LGOB0', date: '2026-04-01'),
      ]);

      expect(list.records.map((r) => r.gameId), [
        '20261126LGOB2',
        '20261126LGOB1',
        '20260401LGOB0',
        '20250901LGOB0',
      ]);
      expect(list.last!.gameId, '20261126LGOB2');
      expect(list.seasons.map((s) => s.title), ['2026 시즌', '2025 시즌']);
      expect(list.seasons.first.records, hasLength(3));
    });
  });

  group('AttendanceRecord', () {
    AttendanceRecord record(AttendanceGame game) => AttendanceRecord.create(
      id: 'id',
      game: game,
      source: AttendanceRecordSource.summary,
      now: t1,
    );

    test('shows the HOME last-attendance line', () {
      expect(
        record(attendanceGame('g1')).lastAttendanceText,
        '마지막 직관 11.26 (목) 잠실 · LG 5:3 두산',
      );
      expect(
        record(
          attendanceGame('g1', stadium: null, status: GameStatus.scheduled),
        ).lastAttendanceText,
        '마지막 직관 11.26 (목) · LG vs 두산',
      );
    });

    test('shows win, loss or draw only for the favorite team', () {
      final game = record(attendanceGame('g1'));
      expect(game.badgeFor('LG'), AttendanceBadge.win);
      expect(game.badgeFor('OB'), AttendanceBadge.loss);
      expect(game.badgeFor('NC'), isNull);
      expect(game.badgeFor(null), isNull);
      expect(
        record(attendanceGame('g1', homeScore: 2, awayScore: 2)).badgeFor('OB'),
        AttendanceBadge.draw,
      );
    });

    test('shows the status for games that did not finish', () {
      AttendanceBadge? badge(GameStatus status) =>
          record(attendanceGame('g1', status: status)).badgeFor('LG');

      expect(badge(GameStatus.scheduled), AttendanceBadge.beforeGame);
      expect(badge(GameStatus.inProgress), AttendanceBadge.inGame);
      expect(badge(GameStatus.cancelled), AttendanceBadge.cancelled);
      expect(badge(GameStatus.postponed), AttendanceBadge.postponed);
    });

    test('falls back to the team code for an unknown team', () {
      expect(record(attendanceGame('g1', away: 'XX')).matchupText, 'LG 5:3 XX');
    });
  });

  group('canAttend', () {
    const today = '2026-11-28';

    test('allows games up to today', () {
      for (final date in ['2026-11-27', today]) {
        expect(
          canAttend(gameDate: date, status: GameStatus.finished, today: today),
          isTrue,
        );
      }
      expect(
        canAttend(gameDate: today, status: GameStatus.scheduled, today: today),
        isTrue,
      );
    });

    test('rejects future, cancelled and postponed games', () {
      expect(
        canAttend(
          gameDate: '2026-11-29',
          status: GameStatus.scheduled,
          today: today,
        ),
        isFalse,
      );
      for (final status in [GameStatus.cancelled, GameStatus.postponed]) {
        expect(
          canAttend(gameDate: '2026-11-27', status: status, today: today),
          isFalse,
        );
      }
    });
  });
}
