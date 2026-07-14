import 'dart:io';

abstract final class AppConstants {
  static const String _baseUrlOverride = String.fromEnvironment('BASE_URL');

  /// 안드로이드 에뮬레이터는 호스트 PC를 `10.0.2.2`로 바라본다.
  /// 실기기에서 로컬 서버를 쓰려면 `--dart-define=BASE_URL=http://<PC-IP>:3651`로 덮어쓴다.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }
    return Platform.isAndroid
        ? 'http://10.0.2.2:3651'
        : 'http://localhost:3651';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
