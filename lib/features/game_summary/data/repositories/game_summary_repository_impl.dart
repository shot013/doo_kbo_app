import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/game_summary.dart';
import '../../domain/repositories/game_summary_repository.dart';
import '../datasources/game_summary_remote_data_source.dart';

class GameSummaryRepositoryImpl implements GameSummaryRepository {
  const GameSummaryRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final GameSummaryRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<GameSummary>> getGameSummary(String gameId) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final summary = await _remoteDataSource.getGameSummary(gameId);
      return Ok(summary);
    } on NotFoundException catch (e) {
      return Err(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
