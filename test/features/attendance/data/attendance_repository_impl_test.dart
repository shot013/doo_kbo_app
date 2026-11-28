import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/utils/result.dart';
import 'package:jikgwan/features/attendance/data/models/attendance_record_model.dart';
import 'package:jikgwan/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:jikgwan/features/attendance/domain/entities/attendance_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../attendance_test_helpers.dart';

void main() {
  const key = AttendanceRepositoryImpl.storageKey;
  final record = AttendanceRecord.create(
    id: 'id-1',
    game: attendanceGame('20261126OBLG0'),
    source: AttendanceRecordSource.summary,
    now: DateTime.utc(2026, 11, 28, 4),
  );
  final recordJson = AttendanceRecordModel.fromEntity(record).toJson();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  Map<String, dynamic> stored(SharedPreferences prefs) =>
      jsonDecode(prefs.getString(key)!) as Map<String, dynamic>;

  List<AttendanceRecord> loaded(AttendanceRepositoryImpl repository) =>
      switch (repository.loadRecords()) {
        Ok(:final value) => value,
        Err(:final failure) => fail('load failed: ${failure.message}'),
      };

  test('starts empty and saves schemaVersion 1 with the records', () async {
    final prefs = await prefsWith({});
    final repository = AttendanceRepositoryImpl(prefs);
    expect(loaded(repository), isEmpty);

    await repository.saveRecords([record]);

    expect(stored(prefs), {
      'schemaVersion': 1,
      'records': [recordJson],
    });
    expect(loaded(AttendanceRepositoryImpl(prefs)), [record]);
  });

  test('migrates an older schema step by step and writes it back', () async {
    // v1 → v2 변환 예: 구장 이름을 바꾸는 가상의 변경.
    final prefs = await prefsWith({
      key: jsonEncode({
        'schemaVersion': 1,
        'records': [recordJson],
      }),
    });
    final repository = AttendanceRepositoryImpl(
      prefs,
      targetVersion: 2,
      migrations: {
        1: (storage) => {
          ...storage,
          'records': [
            for (final item in storage['records'] as List<dynamic>)
              {...item as Map<String, dynamic>, 'stadium': '잠실야구장'},
          ],
        },
      },
    );

    final records = loaded(repository);
    await pumpEventQueue();

    expect(records.single.stadium, '잠실야구장');
    expect(records.single.id, 'id-1');
    final written = stored(prefs);
    expect(written['schemaVersion'], 2);
    expect(
      ((written['records'] as List<dynamic>).single
          as Map<String, dynamic>)['stadium'],
      '잠실야구장',
    );
  });

  test('keeps a newer schema read-only instead of overwriting it', () async {
    final raw = jsonEncode({
      'schemaVersion': 2,
      'records': [recordJson],
    });
    final prefs = await prefsWith({key: raw});
    final repository = AttendanceRepositoryImpl(prefs);

    expect(repository.loadRecords(), isA<Err<List<AttendanceRecord>>>());
    expect(await repository.saveRecords([]), isA<Err<void>>());
    expect(prefs.getString(key), raw);
  });

  test('backs up unreadable data and lets new records be saved', () async {
    final prefs = await prefsWith({key: '{not json'});
    final repository = AttendanceRepositoryImpl(prefs);

    expect(repository.loadRecords(), isA<Err<List<AttendanceRecord>>>());
    await pumpEventQueue();
    expect(prefs.getString(AttendanceRepositoryImpl.backupKey), '{not json');

    expect(await repository.saveRecords([record]), isA<Ok<void>>());
    expect(loaded(repository), [record]);
  });
}
