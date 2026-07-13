import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/standing_remote_data_source.dart';
import '../../data/repositories/standing_repository_impl.dart';
import '../../domain/entities/standing.dart';
import '../../domain/repositories/standing_repository.dart';
import '../../domain/usecases/get_standings.dart';

// 백엔드가 준비되면 아래를 `StandingRemoteDataSourceImpl(ref.watch(dioProvider))`로
// 교체하세요. (import '../../../../core/network/dio_client.dart' 필요)
final standingRemoteDataSourceProvider = Provider<StandingRemoteDataSource>((
  ref,
) {
  return const StandingDummyDataSource();
});

final standingRepositoryProvider = Provider<StandingRepository>((ref) {
  return StandingRepositoryImpl(
    ref.watch(standingRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getStandingsProvider = Provider<GetStandings>((ref) {
  return GetStandings(ref.watch(standingRepositoryProvider));
});

final standingListProvider =
    AsyncNotifierProvider<StandingListNotifier, List<Standing>>(
      StandingListNotifier.new,
    );

class StandingListNotifier extends AsyncNotifier<List<Standing>> {
  @override
  Future<List<Standing>> build() async {
    final result = await ref
        .read(getStandingsProvider)
        .call(const GetStandingsParams());
    return switch (result) {
      Ok<List<Standing>>(:final value) => value,
      Err<List<Standing>>(:final failure) => throw failure,
    };
  }
}
