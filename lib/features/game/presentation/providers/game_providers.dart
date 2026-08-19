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

/// 오늘 이전 날짜 중, 종료된 경기가 있는 가장 최근 경기일을 찾아
/// 그날의 경기 결과를 반환한다. (휴식일 등으로 경기가 없는 날을 대비해
/// 최근 [_lookbackDays]일을 한 번에 병렬 조회한 뒤 가장 최근 날짜를 고른다.)
class RecentFinishedGamesNotifier extends AsyncNotifier<List<Game>> {
  static const _lookbackDays = 7;

  @override
  Future<List<Game>> build() async {
    final getGames = ref.read(getGamesProvider);
    final today = DateTime.now();
    final results = await Future.wait([
      for (var i = 1; i <= _lookbackDays; i++)
        getGames.call(
          GetGamesParams(
            gameDate: _dateString(today.subtract(Duration(days: i))),
          ),
        ),
    ]);

    final finishedByDate = <String, List<Game>>{};
    for (final result in results) {
      final games = switch (result) {
        Ok<List<Game>>(:final value) => value,
        Err<List<Game>>(:final failure) => throw failure,
      };
      final finished = games
          .where((game) => game.status == GameStatus.finished)
          .toList();
      if (finished.isNotEmpty) {
        finishedByDate[finished.first.gameDate] = finished;
      }
    }
    if (finishedByDate.isEmpty) return const [];

    final latestGameDate = finishedByDate.keys.reduce(
      (a, b) => a.compareTo(b) >= 0 ? a : b,
    );
    return finishedByDate[latestGameDate]!;
  }

  String _dateString(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
