import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/team_detail.dart';
import '../../domain/entities/team_summary.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_data_source.dart';

class TeamRepositoryImpl implements TeamRepository {
  const TeamRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final TeamRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<List<TeamSummary>>> getTeams() async {
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

  @override
  Future<Result<TeamDetail>> getTeamDetail(String code) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final detail = await _remoteDataSource.getTeamDetail(code);
      return Ok(detail);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
