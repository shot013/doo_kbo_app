import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/pitcher_record.dart';
import '../repositories/record_repository.dart';

class GetPitcherRecordsParams {
  const GetPitcherRecordsParams({this.seasonYear});

  final int? seasonYear;
}

final class GetPitcherRecords
    extends UseCase<List<PitcherRecord>, GetPitcherRecordsParams> {
  const GetPitcherRecords(this._repository);

  final RecordRepository _repository;

  @override
  Future<Result<List<PitcherRecord>>> call(GetPitcherRecordsParams params) {
    return _repository.getPitcherRecords(seasonYear: params.seasonYear);
  }
}
