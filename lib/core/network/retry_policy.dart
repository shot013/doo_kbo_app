import '../error/failures.dart';

/// 다시 해도 결과가 같은 오류(404, 오프라인)는 재시도 없이 바로 보이고, 서버
/// 오류만 짧게 두 번까지 재시도한다. Riverpod provider의 `retry`에 넘긴다.
/// (앱 전체의 기본 재시도 BUG-09는 그대로 둔다.)
Duration? retryServerErrorsOnly(int retryCount, Object error) {
  if (error is NotFoundFailure || error is NetworkFailure) return null;
  if (retryCount >= 2) return null;
  return Duration(milliseconds: 500 * (retryCount + 1));
}
