sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;
}

final class ServerFailure extends AppFailure {
  const ServerFailure([super.message = '서버 오류가 발생했습니다.']);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해주세요.']);
}

final class CacheFailure extends AppFailure {
  const CacheFailure([super.message = '캐시 오류가 발생했습니다.']);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다.']);
}
