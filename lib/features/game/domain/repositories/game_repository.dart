import '../../../../core/utils/result.dart';
import '../entities/game.dart';
import '../entities/game_stat.dart';

abstract interface class GameRepository {
  Future<Result<List<Game>>> getGames({int? seasonYear, String? gameDate});

  Future<Result<List<GameStat>>> getGameStats(String gameId);
}
