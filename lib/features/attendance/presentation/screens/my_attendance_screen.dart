import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../favorite_team/presentation/providers/favorite_team_providers.dart';
import '../../../game_summary/presentation/screens/game_summary_screen.dart';
import '../../data/datasources/attendance_analytics.dart';
import '../../domain/entities/attendance_list.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/attendance_providers.dart';
import '../widgets/attendance_snack_bar.dart';
import '../widgets/attendance_widgets.dart';
import 'add_attendance_screen.dart';

/// 나의 직관 (정책서 5.9). 기기에 저장한 직관 기록을 시즌별로 보인다.
class MyAttendanceScreen extends ConsumerStatefulWidget {
  const MyAttendanceScreen({super.key});

  static const routeName = 'myAttendance';
  static const routePath = '/my-attendance';

  @override
  ConsumerState<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends ConsumerState<MyAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // 끝나지 않았던 경기만 다시 받아 점수·상태를 갱신한다.
    unawaited(ref.read(attendanceRecordsProvider.notifier).refreshUnfinished());
  }

  void _openAddScreen() => context.pushNamed(AddAttendanceScreen.routeName);

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(attendanceRecordsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('나의 직관')),
      body: list.isEmpty
          ? _EmptyState(onAdd: _openAddScreen)
          : _AttendanceListView(list: list, onAdd: _openAddScreen),
    );
  }
}

class _AttendanceListView extends ConsumerWidget {
  const _AttendanceListView({required this.list, required this.onAdd});

  final AttendanceList list;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteTeamCode = ref.watch(favoriteTeamCodeProvider).value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _SummaryCard(countText: list.countText, onAdd: onAdd),
        for (final season in list.seasons) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              season.title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AttendanceCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  for (var i = 0; i < season.records.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.surfaceHigh,
                      ),
                    _DismissibleRow(
                      record: season.records[i],
                      badge: season.records[i].badgeFor(favoriteTeamCode),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Text(
          '기록은 이 휴대폰에만 저장돼요. 앱을 지우면 함께 지워져요.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _DismissibleRow extends ConsumerWidget {
  const _DismissibleRow({required this.record, required this.badge});

  final AttendanceRecord record;
  final AttendanceBadge? badge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(attendanceRecordsProvider.notifier);
    return Dismissible(
      key: ValueKey('attendance-${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.surfaceHigh,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppColors.textMuted),
      ),
      onDismissed: (_) {
        // 해제하면 이 줄이 목록에서 빠지므로, 저장을 기다리지 않고 아직 화면에
        // 붙어 있을 때 스낵바를 띄운다.
        unawaited(notifier.uncheck(record.gameId, AttendanceSource.list));
        showAttendanceSnackBar(
          context,
          message: attendanceRemovedMessage,
          actionLabel: '되돌리기',
          onAction: () => notifier.check(record.game, AttendanceSource.list),
        );
      },
      child: AttendanceRow(
        record: record,
        badge: badge,
        onTap: () => context.pushNamed(
          GameSummaryScreen.routeName,
          queryParameters: {'date': record.gameDate, 'gameId': record.gameId},
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.countText, required this.onAdd});

  final String countText;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AttendanceCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '직관한 경기',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  countText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18, color: AppColors.textPrimary),
            label: const Text(
              '경기 추가',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stadium_outlined,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 직관 기록이 없어요',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '다녀온 경기를 추가하면 여기에 쌓여요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                '경기 추가',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
