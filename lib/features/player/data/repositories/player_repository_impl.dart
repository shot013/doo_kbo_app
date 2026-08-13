import '../../../../core/constants/player_position.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/player_detail.dart';
import '../../domain/entities/player_summary.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_remote_data_source.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  const PlayerRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final PlayerRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<PlayerSummary>>> getPlayers({
    String? search,
    String? teamCode,
    PlayerPosition? position,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final players = await _remoteDataSource.getPlayers(
        search: search,
        teamCode: teamCode,
        position: position,
      );
      return Ok(players);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<PlayerDetail>> getPlayerDetail(String id) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final player = await _remoteDataSource.getPlayerDetail(id);
      return Ok(player);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
