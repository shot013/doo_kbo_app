import '../../../../core/utils/result.dart';

abstract interface class FavoriteTeamRepository {
  Future<Result<String?>> getFavoriteTeamCode();

  Future<Result<void>> setFavoriteTeamCode(String? teamCode);
}
