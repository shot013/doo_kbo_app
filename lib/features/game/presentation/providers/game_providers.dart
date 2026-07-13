import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/game_remote_data_source.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_stat.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/get_game_stats.dart';
import '../../domain/usecases/get_games.dart';

// 백엔드가 준비되면 아래를 `GameRemoteDataSourceImpl(ref.watch(dioProvider))`로
// 교체하세요. (import '../../../../core/network/dio_client.dart' 필요)
final gameRemoteDataSourceProvider = Provider<GameRemoteDataSource>((ref) {
  return const GameDummyDataSource();
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    ref.watch(gameRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getGamesProvider = Provider<GetGames>((ref) {
  return GetGames(ref.watch(gameRepositoryProvider));
});

final getGameStatsProvider = Provider<GetGameStats>((ref) {
  return GetGameStats(ref.watch(gameRepositoryProvider));
});

final gameListProvider = AsyncNotifierProvider<GameListNotifier, List<Game>>(
  GameListNotifier.new,
);

class GameListNotifier extends AsyncNotifier<List<Game>> {
  @override
  Future<List<Game>> build() async {
    final result = await ref
        .read(getGamesProvider)
        .call(const GetGamesParams());
    return switch (result) {
      Ok<List<Game>>(:final value) => value,
      Err<List<Game>>(:final failure) => throw failure,
    };
  }
}

final gameStatsProvider = FutureProvider.family<List<GameStat>, String>((
  ref,
  gameId,
) async {
  final result = await ref
      .read(getGameStatsProvider)
      .call(GetGameStatsParams(gameId: gameId));
  return switch (result) {
    Ok<List<GameStat>>(:final value) => value,
    Err<List<GameStat>>(:final failure) => throw failure,
  };
});
