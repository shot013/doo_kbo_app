import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/batter_record.dart';
import '../../domain/entities/pitcher_record.dart';
import '../../domain/repositories/record_repository.dart';
import '../datasources/record_remote_data_source.dart';

class RecordRepositoryImpl implements RecordRepository {
  const RecordRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final RecordRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<BatterRecord>>> getBatterRecords({int? seasonYear}) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final records = await _remoteDataSource.getBatterRecords(
        seasonYear: seasonYear,
      );
      return Ok(records);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<List<PitcherRecord>>> getPitcherRecords({
    int? seasonYear,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final records = await _remoteDataSource.getPitcherRecords(
        seasonYear: seasonYear,
      );
      return Ok(records);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
