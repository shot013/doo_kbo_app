final class ServerException implements Exception {
  const ServerException([this.message = '서버 오류가 발생했습니다.']);

  final String message;
}

final class CacheException implements Exception {
  const CacheException([this.message = '캐시 오류가 발생했습니다.']);

  final String message;
}
