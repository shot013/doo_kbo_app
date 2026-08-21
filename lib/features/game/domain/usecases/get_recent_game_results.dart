import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/game_result.dart';
import '../repositories/game_repository.dart';

class GetRecentGameResultsParams {
  const GetRecentGameResultsParams({this.date});

  final String? date;
}

final class GetRecentGameResults
    extends UseCase<List<GameResult>, GetRecentGameResultsParams> {
  const GetRecentGameResults(this._repository);

  final GameRepository _repository;

  @override
  Future<Result<List<GameResult>>> call(GetRecentGameResultsParams params) {
    return _repository.getRecentGameResults(date: params.date);
  }
}
