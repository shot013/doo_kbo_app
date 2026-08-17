import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/team_remote_data_source.dart';
import '../../data/repositories/team_repository_impl.dart';
import '../../domain/entities/team_detail.dart';
import '../../domain/entities/team_summary.dart';
import '../../domain/repositories/team_repository.dart';
import '../../domain/usecases/get_team_detail.dart';
import '../../domain/usecases/get_teams.dart';

final teamRemoteDataSourceProvider = Provider<TeamRemoteDataSource>((ref) {
  return TeamRemoteDataSourceImpl(ref.watch(dioProvider));
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

final getTeamDetailProvider = Provider<GetTeamDetail>((ref) {
  return GetTeamDetail(ref.watch(teamRepositoryProvider));
});

final teamListProvider =
    AsyncNotifierProvider<TeamListNotifier, List<TeamSummary>>(
      TeamListNotifier.new,
    );

class TeamListNotifier extends AsyncNotifier<List<TeamSummary>> {
  @override
  Future<List<TeamSummary>> build() async {
    final result = await ref.read(getTeamsProvider).call(const NoParams());
    return switch (result) {
      Ok<List<TeamSummary>>(:final value) => value,
      Err<List<TeamSummary>>(:final failure) => throw failure,
    };
  }
}

final teamDetailProvider = FutureProvider.family<TeamDetail, String>((
  ref,
  code,
) async {
  final result = await ref
      .read(getTeamDetailProvider)
      .call(GetTeamDetailParams(code));
  return switch (result) {
    Ok<TeamDetail>(:final value) => value,
    Err<TeamDetail>(:final failure) => throw failure,
  };
});
