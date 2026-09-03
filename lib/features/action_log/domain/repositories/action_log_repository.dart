import '../../../../core/utils/result.dart';
import '../entities/action_log.dart';

abstract interface class ActionLogRepository {
  Future<Result<void>> sendLogs(List<ActionLog> logs);
}
