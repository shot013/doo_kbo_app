import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/game_preview.dart';
import '../repositories/game_repository.dart';

final class GetGamePreview extends UseCase<GamePreview, GetGamePreviewParams> {
  const GetGamePreview(this._repository);

  final GameRepository _repository;

  @override
  Future<Result<GamePreview>> call(GetGamePreviewParams params) {
    return _repository.getGamePreview(params.gameId);
  }
}

final class GetGamePreviewParams {
  const GetGamePreviewParams(this.gameId);

  final String gameId;
}
