import '../../../../core/constants/player_position.dart';
import '../../../../core/utils/result.dart';
import '../entities/player_detail.dart';
import '../entities/player_summary.dart';

abstract interface class PlayerRepository {
  Future<Result<List<PlayerSummary>>> getPlayers({
    String? search,
    String? teamCode,
    PlayerPosition? position,
  });

  Future<Result<PlayerDetail>> getPlayerDetail(String id);
}
