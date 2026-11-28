import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

/// 직관 체크·해제를 어느 화면에서 했는지.
enum AttendanceSource {
  gameSummary('summary'),
  addScreen('add_screen'),
  list('list');

  const AttendanceSource(this.value);

  final String value;
}

/// 직관 체크·해제 이벤트 (정책서 5.9, 6.3). 사용 규모를 보고 서버 이전 시점을 정한다.
abstract interface class AttendanceAnalytics {
  Future<void> logCheck(String gameId, AttendanceSource source);

  Future<void> logUncheck(String gameId, AttendanceSource source);
}

class FirebaseAttendanceAnalytics implements AttendanceAnalytics {
  const FirebaseAttendanceAnalytics();

  static const checkEvent = 'attendance_check';
  static const uncheckEvent = 'attendance_uncheck';

  // 위젯 테스트는 Firebase를 초기화하지 않으므로 그때는 보내지 않는다.
  bool get _enabled => Firebase.apps.isNotEmpty;

  @override
  Future<void> logCheck(String gameId, AttendanceSource source) =>
      _log(checkEvent, gameId, source);

  @override
  Future<void> logUncheck(String gameId, AttendanceSource source) =>
      _log(uncheckEvent, gameId, source);

  Future<void> _log(String name, String gameId, AttendanceSource source) async {
    if (!_enabled) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: {'game_id': gameId, 'source': source.value},
      );
    } catch (_) {
      // 분석 이벤트 실패는 사용자 동작에 영향을 주지 않는다.
    }
  }
}
