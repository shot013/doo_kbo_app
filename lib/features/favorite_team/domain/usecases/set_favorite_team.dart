import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/favorite_team_repository.dart';

final class SetFavoriteTeam extends UseCase<void, SetFavoriteTeamParams> {
  const SetFavoriteTeam(this._repository);

  final FavoriteTeamRepository _repository;

  @override
  Future<Result<void>> call(SetFavoriteTeamParams params) {
    return _repository.setFavoriteTeamCode(params.teamCode);
  }
}

final class SetFavoriteTeamParams {
  const SetFavoriteTeamParams(this.teamCode);

  /// null이면 즐겨찾기 해제.
  final String? teamCode;
}
