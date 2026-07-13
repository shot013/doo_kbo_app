import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/standing.dart';
import '../../domain/repositories/standing_repository.dart';
import '../datasources/standing_remote_data_source.dart';

class StandingRepositoryImpl implements StandingRepository {
  const StandingRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final StandingRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<Standing>>> getStandings({int? seasonYear}) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final standings = await _remoteDataSource.getStandings(
        seasonYear: seasonYear,
      );
      return Ok(standings);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
