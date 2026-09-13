import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/favorite_team_repository.dart';

final class GetFavoriteTeam extends UseCase<String?, NoParams> {
  const GetFavoriteTeam(this._repository);

  final FavoriteTeamRepository _repository;

  @override
  Future<Result<String?>> call(NoParams params) {
    return _repository.getFavoriteTeamCode();
  }
}
