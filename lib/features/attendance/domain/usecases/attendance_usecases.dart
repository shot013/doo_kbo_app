import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

/// 저장된 직관 기록을 읽는다. 기기 저장소라 동기로 읽어 화면이 바로 그린다.
final class GetAttendanceRecords {
  const GetAttendanceRecords(this._repository);

  final AttendanceRepository _repository;

  Result<List<AttendanceRecord>> call() => _repository.loadRecords();
}

final class SaveAttendanceRecords
    extends UseCase<void, List<AttendanceRecord>> {
  const SaveAttendanceRecords(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<Result<void>> call(List<AttendanceRecord> params) =>
      _repository.saveRecords(params);
}
