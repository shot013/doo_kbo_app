import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/team_summary.dart';
import '../repositories/team_repository.dart';

final class GetTeams extends UseCase<List<TeamSummary>, NoParams> {
  const GetTeams(this._repository);

  final TeamRepository _repository;

  @override
  Future<Result<List<TeamSummary>>> call(NoParams params) {
    return _repository.getTeams();
  }
}
