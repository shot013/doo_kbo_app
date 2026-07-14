import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/game.dart';
import '../repositories/game_repository.dart';

class GetGamesParams {
  const GetGamesParams({this.seasonYear, this.gameDate});

  final int? seasonYear;
  final String? gameDate;
}

final class GetGames extends UseCase<List<Game>, GetGamesParams> {
  const GetGames(this._repository);

  final GameRepository _repository;

  @override
  Future<Result<List<Game>>> call(GetGamesParams params) {
    return _repository.getGames(
      seasonYear: params.seasonYear,
      gameDate: params.gameDate,
    );
  }
}
