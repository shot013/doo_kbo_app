import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/standing.dart';
import '../repositories/standing_repository.dart';

class GetStandingsParams {
  const GetStandingsParams({this.seasonYear});

  final int? seasonYear;
}

final class GetStandings extends UseCase<List<Standing>, GetStandingsParams> {
  const GetStandings(this._repository);

  final StandingRepository _repository;

  @override
  Future<Result<List<Standing>>> call(GetStandingsParams params) {
    return _repository.getStandings(seasonYear: params.seasonYear);
  }
}
