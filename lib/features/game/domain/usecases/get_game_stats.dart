import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/game_stat.dart';
import '../repositories/game_repository.dart';

class GetGameStatsParams {
  const GetGameStatsParams({required this.gameId});

  final String gameId;
}

final class GetGameStats extends UseCase<List<GameStat>, GetGameStatsParams> {
  const GetGameStats(this._repository);

  final GameRepository _repository;

  @override
  Future<Result<List<GameStat>>> call(GetGameStatsParams params) {
    return _repository.getGameStats(params.gameId);
  }
}
