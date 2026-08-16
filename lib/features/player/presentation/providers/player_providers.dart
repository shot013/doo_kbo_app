import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/player_position.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/player_remote_data_source.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../domain/entities/player_detail.dart';
import '../../domain/entities/player_summary.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/usecases/get_player_detail.dart';
import '../../domain/usecases/get_players.dart';

final playerRemoteDataSourceProvider = Provider<PlayerRemoteDataSource>((ref) {
  return PlayerRemoteDataSourceImpl(ref.watch(dioProvider));
});

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepositoryImpl(
    ref.watch(playerRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getPlayersProvider = Provider<GetPlayers>((ref) {
  return GetPlayers(ref.watch(playerRepositoryProvider));
});

final getPlayerDetailProvider = Provider<GetPlayerDetail>((ref) {
  return GetPlayerDetail(ref.watch(playerRepositoryProvider));
});

final playerListProvider =
    AsyncNotifierProvider<PlayerListNotifier, List<PlayerSummary>>(
      PlayerListNotifier.new,
    );

class PlayerListNotifier extends AsyncNotifier<List<PlayerSummary>> {
  @override
  Future<List<PlayerSummary>> build() async {
    final result = await ref
        .read(getPlayersProvider)
        .call(const GetPlayersParams());
    return switch (result) {
      Ok<List<PlayerSummary>>(:final value) => value,
      Err<List<PlayerSummary>>(:final failure) => throw failure,
    };
  }
}

final playerSearchQueryProvider =
    NotifierProvider<PlayerSearchQueryNotifier, String>(
      PlayerSearchQueryNotifier.new,
    );

class PlayerSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final playerPositionFilterProvider =
    NotifierProvider<PlayerPositionFilterNotifier, PlayerPosition?>(
      PlayerPositionFilterNotifier.new,
    );

class PlayerPositionFilterNotifier extends Notifier<PlayerPosition?> {
  @override
  PlayerPosition? build() => null;

  void select(PlayerPosition? position) => state = position;
}

final playerTeamFilterProvider =
    NotifierProvider<PlayerTeamFilterNotifier, String?>(
      PlayerTeamFilterNotifier.new,
    );

class PlayerTeamFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? teamCode) => state = teamCode;
}

/// [playerListProvider]를 검색어/포지션/팀 필터로 클라이언트 사이드 필터링한 결과.
/// 더미 datasource가 300ms 지연을 흉내내므로, 검색/필터 입력마다 재요청하지
/// 않도록 이미 불러온 전체 목록을 여기서만 걸러낸다.
final filteredPlayersProvider = Provider<AsyncValue<List<PlayerSummary>>>((
  ref,
) {
  final playersAsync = ref.watch(playerListProvider);
  final query = ref.watch(playerSearchQueryProvider).trim();
  final position = ref.watch(playerPositionFilterProvider);
  final teamCode = ref.watch(playerTeamFilterProvider);

  return playersAsync.whenData((players) {
    return players.where((player) {
      final matchesQuery =
          query.isEmpty ||
          player.name.contains(query) ||
          player.teamName.contains(query);
      final matchesPosition = position == null || player.position == position;
      final matchesTeam = teamCode == null || player.teamCode == teamCode;
      return matchesQuery && matchesPosition && matchesTeam;
    }).toList();
  });
});

final playerDetailProvider = FutureProvider.family<PlayerDetail, String>((
  ref,
  playerId,
) async {
  final result = await ref
      .read(getPlayerDetailProvider)
      .call(GetPlayerDetailParams(playerId));
  return switch (result) {
    Ok<PlayerDetail>(:final value) => value,
    Err<PlayerDetail>(:final failure) => throw failure,
  };
});
