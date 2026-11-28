import 'attendance_record.dart';

/// 직관 체크·해제를 어느 화면에서 했는지. Analytics `source` 값으로 쓴다.
enum AttendanceSource {
  gameSummary('summary'),
  addScreen('add_screen'),
  list('list');

  const AttendanceSource(this.value);

  final String value;

  /// 새 기록에 남길 추가 경로. 목록에서는 새로 추가하지 않고 되살리기만 하므로
  /// 경기 요약과 같이 둔다.
  AttendanceRecordSource get recordSource => this == addScreen
      ? AttendanceRecordSource.addScreen
      : AttendanceRecordSource.summary;
}
