import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/team.dart';
import '../repositories/team_repository.dart';

final class GetTeams extends UseCase<List<Team>, NoParams> {
  const GetTeams(this._repository);

  final TeamRepository _repository;

  @override
  Future<Result<List<Team>>> call(NoParams params) {
    return _repository.getTeams();
  }
}
