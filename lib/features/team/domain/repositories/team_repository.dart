import '../../../../core/utils/result.dart';
import '../entities/team_detail.dart';
import '../entities/team_summary.dart';

abstract interface class TeamRepository {
  Future<Result<List<TeamSummary>>> getTeams();

  Future<Result<TeamDetail>> getTeamDetail(String code);
}
