import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_data_source.dart';

class TeamRepositoryImpl implements TeamRepository {
  const TeamRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final TeamRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<Team>>> getTeams() async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final teams = await _remoteDataSource.getTeams();
      return Ok(teams);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
