import 'package:equatable/equatable.dart';

import 'attendance_record.dart';

/// 시즌 하나에 묶인 직관 기록. 최근 경기 순.
class AttendanceSeason extends Equatable {
  const AttendanceSeason({required this.year, required this.records});

  final int year;
  final List<AttendanceRecord> records;

  /// 예: `2026 시즌`
  String get title => '$year 시즌';

  @override
  List<Object?> get props => [year, records];
}

/// 기기에 저장된 직관 기록 전체 (정책서 5.9, 6.3).
///
/// 해제한 기록도 서버 이전 전까지 [allRecords]에 남기고, 화면과 개수는
/// 살아 있는 [records]만 쓴다.
class AttendanceList extends Equatable {
  AttendanceList(Iterable<AttendanceRecord> allRecords)
    : allRecords = List.unmodifiable(allRecords),
      records = List.unmodifiable(
        allRecords.where((r) => !r.isDeleted).toList()..sort(_newestFirst),
      );

  /// 저장할 전체 기록 (해제한 기록 포함).
  final List<AttendanceRecord> allRecords;

  /// 살아 있는 기록. 경기일이 늦은 순.
  final List<AttendanceRecord> records;

  /// 경기일이 늦은 순, 같은 날이면 경기 id 역순(더블헤더 2차전 먼저).
  static int _newestFirst(AttendanceRecord a, AttendanceRecord b) {
    final byDate = b.gameDate.compareTo(a.gameDate);
    if (byDate != 0) return byDate;
    return b.gameId.compareTo(a.gameId);
  }

  bool get isEmpty => records.isEmpty;

  int get count => records.length;

  /// 예: `4경기`
  String get countText => '$count경기';

  /// 가장 최근 경기일의 기록. 없으면 null.
  AttendanceRecord? get last => records.isEmpty ? null : records.first;

  bool contains(String gameId) => records.any((r) => r.gameId == gameId);

  /// 최근 시즌 먼저.
  List<AttendanceSeason> get seasons {
    final byYear = <int, List<AttendanceRecord>>{};
    for (final record in records) {
      byYear.putIfAbsent(record.seasonYear, () => []).add(record);
    }
    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final year in years)
        AttendanceSeason(year: year, records: byYear[year]!),
    ];
  }

  AttendanceRecord? _anyFor(String gameId) {
    for (final record in allRecords) {
      if (record.gameId == gameId) return record;
    }
    return null;
  }

  /// 체크. 이미 살아 있으면 그대로, 해제했던 경기면 같은 id로 되살리고, 처음이면
  /// [newId]로 새로 만든다.
  AttendanceList check(
    AttendanceGame game, {
    required AttendanceRecordSource source,
    required DateTime now,
    required String Function() newId,
  }) {
    final existing = _anyFor(game.gameId);
    if (existing == null) {
      return AttendanceList([
        ...allRecords,
        AttendanceRecord.create(
          id: newId(),
          game: game,
          source: source,
          now: now,
        ),
      ]);
    }
    if (!existing.isDeleted) return this;
    return _replace(existing.restored(game, now));
  }

  /// 해제(소프트 삭제). 살아 있는 기록이 없으면 그대로.
  AttendanceList uncheck(String gameId, {required DateTime now}) {
    final existing = _anyFor(gameId);
    if (existing == null || existing.isDeleted) return this;
    return _replace(existing.deleted(now));
  }

  /// 다시 받은 경기로 점수·상태 캐시를 갱신한다.
  AttendanceList refresh(Iterable<AttendanceGame> games) {
    final byId = {for (final game in games) game.gameId: game};
    return AttendanceList([
      for (final record in allRecords)
        if (byId[record.gameId] case final game? when !record.isDeleted)
          record.refreshed(game)
        else
          record,
    ]);
  }

  AttendanceList _replace(AttendanceRecord updated) => AttendanceList([
    for (final record in allRecords) record.id == updated.id ? updated : record,
  ]);

  @override
  List<Object?> get props => [allRecords];
}
