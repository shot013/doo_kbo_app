import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_source.dart';
import '../providers/attendance_providers.dart';
import '../screens/my_attendance_screen.dart';
import 'attendance_snack_bar.dart';

/// 경기 요약 점수 카드 아래 버튼. `이 경기 직관했어요` ⇄ `직관한 경기예요`
/// (정책서 5.8, 5.9).
class AttendGameButton extends ConsumerWidget {
  const AttendGameButton({required this.game, super.key});

  final GameResult game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attended = ref.watch(
      attendanceRecordsProvider.select((list) => list.contains(game.gameId)),
    );
    final notifier = ref.read(attendanceRecordsProvider.notifier);
    final attendanceGame = AttendanceGame.fromGameResult(game);

    Future<void> check() =>
        notifier.check(attendanceGame, AttendanceSource.gameSummary);

    Future<void> onPressed() async {
      if (attended) {
        await notifier.uncheck(game.gameId, AttendanceSource.gameSummary);
        if (!context.mounted) return;
        showAttendanceSnackBar(
          context,
          message: attendanceRemovedMessage,
          actionLabel: '되돌리기',
          onAction: check,
        );
      } else {
        await check();
        if (!context.mounted) return;
        showAttendanceSnackBar(
          context,
          message: attendanceAddedMessage,
          actionLabel: '보기',
          onAction: () => context.pushNamed(MyAttendanceScreen.routeName),
        );
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          attended ? Icons.check_circle : Icons.add,
          size: 18,
          color: attended ? AppColors.accent : AppColors.textPrimary,
        ),
        label: Text(
          attended ? '직관한 경기예요' : '이 경기 직관했어요',
          style: TextStyle(
            color: attended ? AppColors.accent : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: attended
              ? AppColors.accent.withValues(alpha: 0.16)
              : null,
          side: BorderSide(
            color: attended ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
