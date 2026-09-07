import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/action_log.dart';
import '../../domain/repositories/action_log_repository.dart';
import '../datasources/action_log_remote_data_source.dart';
import '../models/action_log_model.dart';

class ActionLogRepositoryImpl implements ActionLogRepository {
  const ActionLogRepositoryImpl(this._remoteDataSource, this._networkInfo);

  final ActionLogRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Result<void>> sendLogs(List<ActionLog> logs) async {
    if (!await _networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      await _remoteDataSource.sendLogs(
        logs.map(ActionLogModel.fromEntity).toList(),
      );
      return const Ok(null);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
