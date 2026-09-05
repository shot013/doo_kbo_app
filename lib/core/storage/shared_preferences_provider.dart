import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `main()`에서 `SharedPreferences.getInstance()`로 얻은 인스턴스로 반드시
/// override해서 사용한다. `SharedPreferences`는 비동기로만 얻을 수 있는데,
/// 이 값을 필요로 하는 provider들이 동기 `Provider`이길 원해서 앱 시작 시점에
/// 미리 얻어 override하는 방식을 쓴다.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider를 main()에서 override해야 합니다.',
  );
});
