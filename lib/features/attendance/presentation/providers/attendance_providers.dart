import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/retry_policy.dart';
import '../../../../core/storage/shared_preferences_provider.dart';
import '../../../../core/utils/date_label.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/uuid.dart';
import '../../../game/domain/entities/game.dart';
import '../../../game/domain/usecases/get_games.dart';
import '../../../game/presentation/providers/game_providers.dart';
import '../../data/datasources/attendance_analytics.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_list.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/attendance_usecases.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(sharedPreferencesProvider));
});

final getAttendanceRecordsProvider = Provider<GetAttendanceRecords>((ref) {
  return GetAttendanceRecords(ref.watch(attendanceRepositoryProvider));
});

final saveAttendanceRecordsProvider = Provider<SaveAttendanceRecords>((ref) {
  return SaveAttendanceRecords(ref.watch(attendanceRepositoryProvider));
});

final attendanceAnalyticsProvider = Provider<AttendanceAnalytics>((ref) {
  return const FirebaseAttendanceAnalytics();
});

/// 지금 시각. 테스트에서 고정하려고 provider로 둔다.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// 새 직관 기록 id. 테스트에서 고정하려고 provider로 둔다.
final attendanceIdGeneratorProvider = Provider<String Function()>(
  (ref) => generateUuidV4,
);

/// 오늘 날짜 `YYYY-MM-DD` (HOME 오늘의 경기와 같은 기기 시간대 기준, CODE-04).
String todayDate(WidgetRef ref) => isoDate(ref.read(clockProvider)());

/// 기기에 저장된 직관 기록. HOME 카드, 나의 직관, 경기 추가, 경기 요약 버튼이
/// 같이 보므로 한 곳에서 체크하면 모든 화면이 바로 바뀐다.
final attendanceRecordsProvider =
    NotifierProvider<AttendanceRecordsNotifier, AttendanceList>(
      AttendanceRecordsNotifier.new,
    );

class AttendanceRecordsNotifier extends Notifier<AttendanceList> {
  @override
  AttendanceList build() {
    final result = ref.read(getAttendanceRecordsProvider).call();
    return switch (result) {
      Ok(:final value) => AttendanceList(value),
      // 읽지 못하면 기록이 없는 것처럼 보인다 (MY팀 읽기 실패와 같은 정책, 4.5).
      Err() => AttendanceList(const []),
    };
  }

  DateTime _now() => ref.read(clockProvider)();

  bool isAttended(String gameId) => state.contains(gameId);

  Future<void> check(AttendanceGame game, AttendanceSource source) async {
    if (state.contains(game.gameId)) return;
    state = state.check(
      game,
      source: source == AttendanceSource.addScreen
          ? AttendanceRecordSource.addScreen
          : AttendanceRecordSource.summary,
      now: _now(),
      newId: ref.read(attendanceIdGeneratorProvider),
    );
    await _save();
    unawaited(
      ref.read(attendanceAnalyticsProvider).logCheck(game.gameId, source),
    );
  }

  Future<void> uncheck(String gameId, AttendanceSource source) async {
    if (!state.contains(gameId)) return;
    state = state.uncheck(gameId, now: _now());
    await _save();
    unawaited(ref.read(attendanceAnalyticsProvider).logUncheck(gameId, source));
  }

  /// 끝나지 않았던 경기만 그 날짜의 경기 목록을 다시 받아 점수·상태를 고친다.
  /// 받지 못한 날짜는 저장된 값을 그대로 쓴다 (정책서 5.9).
  Future<void> refreshUnfinished() async {
    final dates = {
      for (final record in state.records)
        if (record.needsRefresh) record.gameDate,
    };
    if (dates.isEmpty) return;
    final getGames = ref.read(getGamesProvider);
    final fetched = <AttendanceGame>[];
    for (final date in dates) {
      final result = await getGames.call(GetGamesParams(gameDate: date));
      if (result case Ok<List<Game>>(:final value)) {
        fetched.addAll(value.map(AttendanceGame.fromGame));
      }
    }
    if (!ref.mounted || fetched.isEmpty) return;
    final refreshed = state.refresh(fetched);
    if (refreshed == state) return;
    state = refreshed;
    await _save();
  }

  Future<void> _save() async {
    final result = await ref
        .read(saveAttendanceRecordsProvider)
        .call(state.allRecords);
    if (result case Err(:final failure)) {
      debugPrint('[attendance] save failed: ${failure.message}');
    }
  }
}

/// 경기 추가 화면에서 고른 날짜. null이면 최근 경기일(없으면 오늘).
final addAttendanceDateProvider =
    NotifierProvider.autoDispose<AddAttendanceDateNotifier, String?>(
      AddAttendanceDateNotifier.new,
    );

class AddAttendanceDateNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String date) => state = date;
}

/// 그날의 경기 (`GET /games?gameDate=`).
final gamesOnDateProvider = FutureProvider.autoDispose
    .family<List<Game>, String>((ref, date) async {
      final result = await ref
          .read(getGamesProvider)
          .call(GetGamesParams(gameDate: date));
      return switch (result) {
        Ok(:final value) => value,
        Err(:final failure) => throw failure,
      };
    }, retry: retryServerErrorsOnly);
