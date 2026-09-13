import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/shared_preferences_provider.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../data/repositories/favorite_team_repository_impl.dart';
import '../../domain/repositories/favorite_team_repository.dart';
import '../../domain/usecases/get_favorite_team.dart';
import '../../domain/usecases/set_favorite_team.dart';

final favoriteTeamRepositoryProvider = Provider<FavoriteTeamRepository>((ref) {
  return FavoriteTeamRepositoryImpl(ref.watch(sharedPreferencesProvider));
});

final getFavoriteTeamProvider = Provider<GetFavoriteTeam>((ref) {
  return GetFavoriteTeam(ref.watch(favoriteTeamRepositoryProvider));
});

final setFavoriteTeamProvider = Provider<SetFavoriteTeam>((ref) {
  return SetFavoriteTeam(ref.watch(favoriteTeamRepositoryProvider));
});

final favoriteTeamCodeProvider =
    AsyncNotifierProvider<FavoriteTeamCodeNotifier, String?>(
      FavoriteTeamCodeNotifier.new,
    );

class FavoriteTeamCodeNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final result = await ref
        .read(getFavoriteTeamProvider)
        .call(const NoParams());
    return switch (result) {
      Ok<String?>(:final value) => value,
      Err<String?>(:final failure) => throw failure,
    };
  }

  Future<void> select(String? teamCode) async {
    final result = await ref
        .read(setFavoriteTeamProvider)
        .call(SetFavoriteTeamParams(teamCode));
    switch (result) {
      case Ok<void>():
        state = AsyncData(teamCode);
      case Err<void>(:final failure):
        state = AsyncError(failure, StackTrace.current);
    }
  }
}
