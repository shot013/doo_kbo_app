abstract final class AppConstants {
  static const String _baseUrlOverride = String.fromEnvironment('BASE_URL');

  /// 로컬 서버로 테스트하려면 `--dart-define=BASE_URL=http://<PC-IP>:3651`로 덮어쓴다.
  ///
  /// 백엔드가 HTTPS 도메인을 갖추면(TODO.md "백엔드 HTTPS 전환" 참고) 이
  /// 기본값도 `https://<도메인>`으로 바꾸고, iOS Info.plist의
  /// NSExceptionDomains(15.164.113.221 예외)도 함께 제거한다.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }
    return 'http://15.164.113.221:3651';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
