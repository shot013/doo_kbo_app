import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../domain/entities/attendance_record.dart';

/// 나의 직관 화면들의 카드 (surface, 모서리 20).
class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? AppColors.surface, width: 1.5),
      ),
      child: child,
    );
  }
}

/// `홈 로고 홈 점수:점수 원정 원정 로고`
class AttendanceMatchup extends StatelessWidget {
  const AttendanceMatchup({
    required this.homeTeamCode,
    required this.awayTeamCode,
    required this.text,
    this.fontSize = 15,
    super.key,
  });

  final String homeTeamCode;
  final String awayTeamCode;
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamLogo(teamCode: homeTeamCode, size: 22),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TeamLogo(teamCode: awayTeamCode, size: 22),
      ],
    );
  }
}

/// 목록 행 오른쪽 배지. 승·패·무는 원형, 경기 전·경기 중·취소·연기는 글자.
class AttendanceBadgeView extends StatelessWidget {
  const AttendanceBadgeView(this.badge, {super.key});

  final AttendanceBadge badge;

  @override
  Widget build(BuildContext context) {
    if (!badge.isResult) {
      return Text(
        badge.label,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }
    final color = badge == AttendanceBadge.win
        ? AppColors.accent
        : AppColors.textMuted;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        badge.label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 나의 직관 목록 행: `MM.DD 요일 | 매치업, 구장 | 배지`.
class AttendanceRow extends StatelessWidget {
  const AttendanceRow({
    required this.record,
    required this.badge,
    required this.onTap,
    super.key,
  });

  final AttendanceRecord record;
  final AttendanceBadge? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badge = this.badge;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    record.monthDayText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.weekdayText,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AttendanceMatchup(
                    homeTeamCode: record.homeTeamCode,
                    awayTeamCode: record.awayTeamCode,
                    text: record.matchupText,
                    fontSize: 14,
                  ),
                  if (record.stadium case final stadium?) ...[
                    const SizedBox(height: 4),
                    Text(
                      stadium,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              AttendanceBadgeView(badge),
            ],
          ],
        ),
      ),
    );
  }
}
