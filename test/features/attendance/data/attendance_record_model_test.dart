import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/attendance/data/models/attendance_record_model.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:jikgwan/features/game/domain/entities/game_status.dart';

import '../attendance_test_helpers.dart';

void main() {
  final record = AttendanceRecord.create(
    id: '0b6f1d2c-8a4e-4f5b-9c3d-2e1f0a9b8c7d',
    game: attendanceGame('20261126OBLG0'),
    source: AttendanceRecordSource.addScreen,
    now: DateTime.utc(2026, 11, 28, 4, 14, 34, 120),
  );

  test('writes camelCase keys with UTC millisecond timestamps', () {
    final json = AttendanceRecordModel.fromEntity(record).toJson();

    expect(json, {
      'id': '0b6f1d2c-8a4e-4f5b-9c3d-2e1f0a9b8c7d',
      'gameId': '20261126OBLG0',
      'seasonYear': 2026,
      'gameDate': '2026-11-26',
      'stadium': '잠실',
      'homeTeamCode': 'LG',
      'awayTeamCode': 'OB',
      'homeScore': 5,
      'awayScore': 3,
      'gameStatus': 'finished',
      'source': 'add_screen',
      'createdAt': '2026-11-28T04:14:34.120Z',
      'updatedAt': '2026-11-28T04:14:34.120Z',
      'deletedAt': null,
    });
  });

  test('round-trips a deleted record', () {
    final deleted = record.deleted(DateTime.utc(2026, 11, 28, 5));
    final json = AttendanceRecordModel.fromEntity(deleted).toJson();

    expect(json['deletedAt'], '2026-11-28T05:00:00.000Z');
    expect(AttendanceRecordModel.fromJson(json).toEntity(), deleted);
  });

  test('formats local times as UTC', () {
    final local = DateTime(2026, 11, 28, 13, 14, 34, 120);
    expect(formatUtcMillis(local), endsWith('Z'));
    expect(DateTime.parse(formatUtcMillis(local)), local.toUtc());
  });

  test('reads unknown status and source leniently', () {
    final json = AttendanceRecordModel.fromEntity(record).toJson()
      ..['gameStatus'] = 'SUSPENDED'
      ..['source'] = 'widget';

    final parsed = AttendanceRecordModel.fromJson(json);

    expect(parsed.gameStatus, GameStatus.scheduled);
    expect(parsed.source, AttendanceRecordSource.summary);
  });
}
