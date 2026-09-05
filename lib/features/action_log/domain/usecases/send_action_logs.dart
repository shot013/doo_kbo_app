import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/action_log.dart';
import '../repositories/action_log_repository.dart';

final class SendActionLogs extends UseCase<void, SendActionLogsParams> {
  const SendActionLogs(this._repository);

  final ActionLogRepository _repository;

  @override
  Future<Result<void>> call(SendActionLogsParams params) {
    return _repository.sendLogs(params.logs);
  }
}

final class SendActionLogsParams {
  const SendActionLogsParams(this.logs);

  final List<ActionLog> logs;
}
