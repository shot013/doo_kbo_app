import '../../../../core/utils/result.dart';
import '../entities/game_summary.dart';

abstract interface class GameSummaryRepository {
  /// 요약 데이터가 아직 없으면 `NotFoundFailure`.
  Future<Result<GameSummary>> getGameSummary(String gameId);
}
