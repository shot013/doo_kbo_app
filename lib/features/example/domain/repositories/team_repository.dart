import '../../../../core/utils/result.dart';
import '../entities/team.dart';

abstract interface class TeamRepository {
  Future<Result<List<Team>>> getTeams();
}
