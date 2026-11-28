import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_storage.dart';

/// SharedPreferences 키 하나에 `{"schemaVersion":1,"records":[...]}`로 저장한다.
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(
    this._preferences, {
    this.targetVersion = currentSchemaVersion,
    this.migrations = attendanceMigrations,
  });

  final SharedPreferences _preferences;
  final int targetVersion;
  final Map<int, AttendanceMigration> migrations;

  static const storageKey = 'attendance_records';
  static const backupKey = 'attendance_records_unreadable_backup';

  /// 앱보다 새 버전의 저장소를 읽었으면 덮어쓰지 않는다.
  bool _readOnly = false;

  @override
  Result<List<AttendanceRecord>> loadRecords() {
    try {
      final raw = _preferences.getString(storageKey);
      if (raw == null) return const Ok([]);
      final stored = jsonDecode(raw) as Map<String, dynamic>;
      final storage = migrateAttendanceStorage(
        stored,
        targetVersion: targetVersion,
        migrations: migrations,
      );
      final records = (storage['records'] as List<dynamic>? ?? const [])
          .map(
            (item) => AttendanceRecordModel.fromJson(
              item as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList();
      if (stored['schemaVersion'] != storage['schemaVersion']) {
        unawaited(_write(records));
      }
      return Ok(records);
    } on UnsupportedAttendanceSchema catch (error) {
      _readOnly = true;
      debugPrint('[attendance] unsupported schemaVersion ${error.version}');
      return const Err(CacheFailure());
    } catch (error) {
      // 깨진 데이터는 따로 남겨 두고 새로 기록할 수 있게 한다.
      debugPrint('[attendance] failed to read records: $error');
      final raw = _preferences.getString(storageKey);
      if (raw != null) unawaited(_preferences.setString(backupKey, raw));
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<void>> saveRecords(List<AttendanceRecord> records) async {
    if (_readOnly) return const Err(CacheFailure());
    try {
      await _write(records);
      return const Ok(null);
    } catch (_) {
      return const Err(CacheFailure());
    }
  }

  Future<void> _write(List<AttendanceRecord> records) async {
    final raw = jsonEncode({
      'schemaVersion': targetVersion,
      'records': [
        for (final record in records)
          AttendanceRecordModel.fromEntity(record).toJson(),
      ],
    });
    await _preferences.setString(storageKey, raw);
  }
}
