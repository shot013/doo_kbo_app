import '../../../../core/utils/result.dart';
import '../entities/attendance_record.dart';

/// 기기에 저장한 직관 기록 (정책서 6.3). 서버로 보내지 않는다.
abstract interface class AttendanceRepository {
  Result<List<AttendanceRecord>> loadRecords();

  Future<Result<void>> saveRecords(List<AttendanceRecord> records);
}
