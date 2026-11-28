import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/game_summary.dart';
import '../repositories/game_summary_repository.dart';

final class GetGameSummary extends UseCase<GameSummary, GetGameSummaryParams> {
  const GetGameSummary(this._repository);

  final GameSummaryRepository _repository;

  @override
  Future<Result<GameSummary>> call(GetGameSummaryParams params) {
    return _repository.getGameSummary(params.gameId);
  }
}

final class GetGameSummaryParams {
  const GetGameSummaryParams(this.gameId);

  final String gameId;
}
