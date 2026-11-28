import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_label.dart';
import '../../../game/domain/entities/game.dart';
import '../../../game/presentation/providers/game_providers.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_source.dart';
import '../providers/attendance_providers.dart';
import '../widgets/attendance_calendar_dialog.dart';
import '../widgets/attendance_widgets.dart';

/// 경기 추가 (정책서 5.9). 날짜를 골라 그날 경기를 눌러 추가·해제한다.
class AddAttendanceScreen extends ConsumerWidget {
  const AddAttendanceScreen({super.key});

  static const routeName = 'addAttendance';

  /// [MyAttendanceScreen.routePath] 아래 `add`.
  static const routePath = 'add';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = todayDate(ref);
    final picked = ref.watch(addAttendanceDateProvider);
    // 기본은 HOME 최근 경기 결과와 같은 최근 경기일, 없으면 오늘.
    final recentDate = ref.watch(
      recentGameResultsProvider.select(
        (results) => results.whenData(
          (games) => games.isEmpty ? null : games.first.gameDate,
        ),
      ),
    );

    final Widget body;
    if (picked == null && recentDate.isLoading) {
      body = const Center(
        child: CircularProgressIndicator(color: AppColors.textPrimary),
      );
    } else {
      final date = picked ?? recentDate.value ?? today;
      body = _AddAttendanceBody(date: date, today: today);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('경기 추가')),
      body: body,
    );
  }
}

class _AddAttendanceBody extends ConsumerWidget {
  const _AddAttendanceBody({required this.date, required this.today});

  final String date;
  final String today;

  void _select(WidgetRef ref, String date) =>
      ref.read(addAttendanceDateProvider.notifier).select(date);

  String _shift(int days) {
    final parsed = DateTime.parse(date);
    return isoDate(DateTime(parsed.year, parsed.month, parsed.day + days));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesOnDateProvider(date));
    final canGoNext = date.compareTo(today) < 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        AttendanceCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: '이전 날',
                onPressed: () => _select(ref, _shift(-1)),
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final chosen = await showAttendanceCalendar(
                      context,
                      selected: date,
                      today: today,
                    );
                    if (chosen != null) _select(ref, chosen);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateWithWeekday(date),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: '다음 날',
                onPressed: canGoNext ? () => _select(ref, _shift(1)) : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoNext ? AppColors.textPrimary : AppColors.border,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '다녀온 경기를 눌러 추가하세요. 다시 누르면 빠져요.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        ...gamesAsync.when(
          data: (games) => games.isEmpty
              ? [const _Message('이 날은 경기가 없어요')]
              : [
                  for (final game in games) ...[
                    _GameTile(game: game, today: today),
                    const SizedBox(height: 10),
                  ],
                ],
          loading: () => [
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.textPrimary),
              ),
            ),
          ],
          error: (error, stackTrace) => [
            _Message(
              error is AppFailure ? error.message : '경기 정보를 불러오지 못했습니다.',
            ),
          ],
        ),
      ],
    );
  }
}

class _GameTile extends ConsumerWidget {
  const _GameTile({required this.game, required this.today});

  final Game game;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attended = ref.watch(
      attendanceRecordsProvider.select((list) => list.contains(game.id)),
    );
    final allowed = canAttend(
      gameDate: game.gameDate,
      status: game.status,
      today: today,
    );
    final notifier = ref.read(attendanceRecordsProvider.notifier);
    final attendanceGame = AttendanceGame.fromGame(game);

    final Widget trailing;
    if (attended) {
      trailing = const Icon(
        Icons.check_circle,
        color: AppColors.accent,
        size: 28,
        semanticLabel: '추가됨',
      );
    } else if (allowed) {
      trailing = const Icon(
        Icons.radio_button_unchecked,
        color: AppColors.textMuted,
        size: 28,
        semanticLabel: '추가 안 됨',
      );
    } else {
      trailing = const Text(
        '추가할 수 없음',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      // 이미 추가한 경기는 취소·연기됐어도 뺄 수 있게 둔다.
      onTap: attended
          ? () => notifier.uncheck(game.id, AttendanceSource.addScreen)
          : allowed
          ? () => notifier.check(attendanceGame, AttendanceSource.addScreen)
          : null,
      child: AttendanceCard(
        borderColor: attended ? AppColors.accent : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendanceGame.placeAndStatusText,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AttendanceMatchup(
                    homeTeamCode: game.homeTeamCode,
                    awayTeamCode: game.awayTeamCode,
                    text: attendanceGame.matchupText,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      ),
    );
  }
}
