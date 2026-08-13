import '../../../../core/constants/player_position.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/player_summary.dart';
import '../repositories/player_repository.dart';

class GetPlayersParams {
  const GetPlayersParams({this.search, this.teamCode, this.position});

  final String? search;
  final String? teamCode;
  final PlayerPosition? position;
}

final class GetPlayers extends UseCase<List<PlayerSummary>, GetPlayersParams> {
  const GetPlayers(this._repository);

  final PlayerRepository _repository;

  @override
  Future<Result<List<PlayerSummary>>> call(GetPlayersParams params) {
    return _repository.getPlayers(
      search: params.search,
      teamCode: params.teamCode,
      position: params.position,
    );
  }
}
