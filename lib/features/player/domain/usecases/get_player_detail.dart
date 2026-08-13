import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/player_detail.dart';
import '../repositories/player_repository.dart';

class GetPlayerDetailParams {
  const GetPlayerDetailParams(this.id);

  final String id;
}

final class GetPlayerDetail
    extends UseCase<PlayerDetail, GetPlayerDetailParams> {
  const GetPlayerDetail(this._repository);

  final PlayerRepository _repository;

  @override
  Future<Result<PlayerDetail>> call(GetPlayerDetailParams params) {
    return _repository.getPlayerDetail(params.id);
  }
}
