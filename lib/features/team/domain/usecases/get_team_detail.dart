import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/team_detail.dart';
import '../repositories/team_repository.dart';

class GetTeamDetailParams {
  const GetTeamDetailParams(this.code);

  final String code;
}

final class GetTeamDetail extends UseCase<TeamDetail, GetTeamDetailParams> {
  const GetTeamDetail(this._repository);

  final TeamRepository _repository;

  @override
  Future<Result<TeamDetail>> call(GetTeamDetailParams params) {
    return _repository.getTeamDetail(params.code);
  }
}
