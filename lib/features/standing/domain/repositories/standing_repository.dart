import '../../../../core/utils/result.dart';
import '../entities/standing.dart';

abstract interface class StandingRepository {
  Future<Result<List<Standing>>> getStandings({int? seasonYear});
}
