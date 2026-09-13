import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/favorite_team_repository.dart';

class FavoriteTeamRepositoryImpl implements FavoriteTeamRepository {
  const FavoriteTeamRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _storageKey = 'favorite_team_code';

  @override
  Future<Result<String?>> getFavoriteTeamCode() async {
    try {
      return Ok(_preferences.getString(_storageKey));
    } catch (_) {
      return const Err(CacheFailure());
    }
  }

  @override
  Future<Result<void>> setFavoriteTeamCode(String? teamCode) async {
    try {
      if (teamCode == null) {
        await _preferences.remove(_storageKey);
      } else {
        await _preferences.setString(_storageKey, teamCode);
      }
      return const Ok(null);
    } catch (_) {
      return const Err(CacheFailure());
    }
  }
}
