import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_stat.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_remote_data_source.dart';

class GameRepositoryImpl implements GameRepository {
  const GameRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final GameRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<Game>>> getGames({
    int? seasonYear,
    String? gameDate,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final games = await _remoteDataSource.getGames(
        seasonYear: seasonYear,
        gameDate: gameDate,
      );
      return Ok(games);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<List<GameStat>>> getGameStats(String gameId) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final stats = await _remoteDataSource.getGameStats(gameId);
      return Ok(stats);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
