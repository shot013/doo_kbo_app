import '../utils/result.dart';

abstract class UseCase<ResultType, Params> {
  const UseCase();

  Future<Result<ResultType>> call(Params params);
}

final class NoParams {
  const NoParams();
}
