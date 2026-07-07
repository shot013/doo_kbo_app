import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/team_remote_data_source.dart';
import '../../data/repositories/team_repository_impl.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';
import '../../domain/usecases/get_teams.dart';

// 백엔드가 준비되면 아래를 `TeamRemoteDataSourceImpl(ref.watch(dioProvider))`로
// 교체하세요. (import '../../../../core/network/dio_client.dart' 필요)
final teamRemoteDataSourceProvider = Provider<TeamRemoteDataSource>((ref) {
  return const TeamDummyDataSource();
});

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepositoryImpl(
    ref.watch(teamRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getTeamsProvider = Provider<GetTeams>((ref) {
  return GetTeams(ref.watch(teamRepositoryProvider));
});

final teamListProvider = AsyncNotifierProvider<TeamListNotifier, List<Team>>(
  TeamListNotifier.new,
);

class TeamListNotifier extends AsyncNotifier<List<Team>> {
  @override
  Future<List<Team>> build() async {
    final result = await ref.read(getTeamsProvider).call(const NoParams());
    return switch (result) {
      Ok<List<Team>>(:final value) => value,
      Err<List<Team>>(:final failure) => throw failure,
    };
  }
}
