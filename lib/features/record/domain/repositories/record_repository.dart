import '../../../../core/utils/result.dart';
import '../entities/batter_record.dart';
import '../entities/pitcher_record.dart';

abstract interface class RecordRepository {
  Future<Result<List<BatterRecord>>> getBatterRecords({int? seasonYear});

  Future<Result<List<PitcherRecord>>> getPitcherRecords({int? seasonYear});
}
