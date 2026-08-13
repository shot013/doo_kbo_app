import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/batter_record.dart';
import '../repositories/record_repository.dart';

class GetBatterRecordsParams {
  const GetBatterRecordsParams({this.seasonYear});

  final int? seasonYear;
}

final class GetBatterRecords
    extends UseCase<List<BatterRecord>, GetBatterRecordsParams> {
  const GetBatterRecords(this._repository);

  final RecordRepository _repository;

  @override
  Future<Result<List<BatterRecord>>> call(GetBatterRecordsParams params) {
    return _repository.getBatterRecords(seasonYear: params.seasonYear);
  }
}
