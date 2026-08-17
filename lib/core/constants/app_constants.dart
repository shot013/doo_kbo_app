abstract final class AppConstants {
  static const String _baseUrlOverride = String.fromEnvironment('BASE_URL');

  /// 로컬 서버로 테스트하려면 `--dart-define=BASE_URL=http://<PC-IP>:3651`로 덮어쓴다.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }
    return 'http://15.164.113.221:3651';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
