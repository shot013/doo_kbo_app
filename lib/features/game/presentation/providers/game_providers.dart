import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/game_remote_data_source.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_stat.dart';
import '../../domain/entities/game_status.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/get_game_stats.dart';
import '../../domain/usecases/get_games.dart';

final gameRemoteDataSourceProvider = Provider<GameRemoteDataSource>((ref) {
  return GameRemoteDataSourceImpl(ref.watch(dioProvider));
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

final todayGamesProvider =
    AsyncNotifierProvider<TodayGamesNotifier, List<Game>>(
      TodayGamesNotifier.new,
    );

class TodayGamesNotifier extends AsyncNotifier<List<Game>> {
  @override
  Future<List<Game>> build() async {
    final result = await ref
        .read(getGamesProvider)
        .call(GetGamesParams(gameDate: _todayDateString()));
    return switch (result) {
      Ok<List<Game>>(:final value) => value,
      Err<List<Game>>(:final failure) => throw failure,
    };
  }

  String _todayDateString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}

final recentFinishedGamesProvider =
    AsyncNotifierProvider<RecentFinishedGamesNotifier, List<Game>>(
      RecentFinishedGamesNotifier.new,
    );

class RecentFinishedGamesNotifier extends AsyncNotifier<List<Game>> {
  @override
  Future<List<Game>> build() async {
    final result = await ref
        .read(getGamesProvider)
        .call(const GetGamesParams());
    final games = switch (result) {
      Ok<List<Game>>(:final value) => value,
      Err<List<Game>>(:final failure) => throw failure,
    };

    final finished = games
        .where((game) => game.status == GameStatus.finished)
        .toList();
    if (finished.isEmpty) return const [];

    final latestGameDate = finished
        .map((game) => game.gameDate)
        .reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
    return finished.where((game) => game.gameDate == latestGameDate).toList();
  }
}
