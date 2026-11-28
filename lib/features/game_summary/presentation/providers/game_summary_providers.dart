import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/game_summary_remote_data_source.dart';
import '../../data/repositories/game_summary_repository_impl.dart';
import '../../domain/entities/game_summary.dart';
import '../../domain/repositories/game_summary_repository.dart';
import '../../domain/usecases/get_game_summary.dart';

final gameSummaryRemoteDataSourceProvider =
    Provider<GameSummaryRemoteDataSource>((ref) {
      return GameSummaryRemoteDataSourceImpl(ref.watch(dioProvider));
    });

final gameSummaryRepositoryProvider = Provider<GameSummaryRepository>((ref) {
  return GameSummaryRepositoryImpl(
    ref.watch(gameSummaryRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final getGameSummaryProvider = Provider<GetGameSummary>((ref) {
  return GetGameSummary(ref.watch(gameSummaryRepositoryProvider));
});

/// 경기 칩을 고를 때 그 경기의 요약만 요청한다. 경기별로 캐시하되 화면을
/// 닫으면 버려서, 다시 열 때 새로 요청한다 (정책서 CODE-01을 이 화면에서는 피함).
final gameSummaryProvider = FutureProvider.autoDispose
    .family<GameSummary, String>((ref, gameId) async {
      final result = await ref
          .read(getGameSummaryProvider)
          .call(GetGameSummaryParams(gameId));
      return switch (result) {
        Ok<GameSummary>(:final value) => value,
        Err<GameSummary>(:final failure) => throw failure,
      };
    }, retry: gameSummaryRetry);

/// 요약 없음(404)과 오프라인은 다시 해도 결과가 같으니 재시도 없이 바로
/// 보이고, 서버 오류만 짧게 두 번까지 재시도한다 (KAN-5 사용자 선택, 앱 전체의
/// 기본 재시도 BUG-09는 그대로 둔다).
Duration? gameSummaryRetry(int retryCount, Object error) {
  if (error is NotFoundFailure || error is NetworkFailure) return null;
  if (retryCount >= 2) return null;
  return Duration(milliseconds: 500 * (retryCount + 1));
}

enum GameSummaryTab { runs, pitching, pinchHitters }

extension GameSummaryTabLabel on GameSummaryTab {
  String get label => switch (this) {
    GameSummaryTab.runs => '이닝별 득·실점',
    GameSummaryTab.pitching => '투수 교체',
    GameSummaryTab.pinchHitters => '대타',
  };
}

/// 선택한 토글. 경기 칩을 바꿔도 유지하고, 화면을 닫으면 기본값으로 돌아간다.
final gameSummaryTabProvider =
    NotifierProvider.autoDispose<GameSummaryTabNotifier, GameSummaryTab>(
      GameSummaryTabNotifier.new,
    );

class GameSummaryTabNotifier extends Notifier<GameSummaryTab> {
  @override
  GameSummaryTab build() => GameSummaryTab.runs;

  void select(GameSummaryTab tab) => state = tab;
}

/// 사용자가 누른 경기 칩. null이면 진입할 때 받은 경기 → MY팀 경기 → 첫 경기
/// 순서로 고른다.
final selectedSummaryGameIdProvider =
    NotifierProvider.autoDispose<SelectedSummaryGameIdNotifier, String?>(
      SelectedSummaryGameIdNotifier.new,
    );

class SelectedSummaryGameIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String gameId) => state = gameId;
}
