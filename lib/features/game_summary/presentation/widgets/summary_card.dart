import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 경기 요약 화면의 카드 (surface, 모서리 20).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

/// 카드 제목 줄. [leading]은 제목 앞(팀 로고 등), [trailing]은 오른쪽 보조 문구.
class SummaryCardTitle extends StatelessWidget {
  const SummaryCardTitle({
    required this.title,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// `1회말`처럼 이닝을 적는 둥근 배지.
class InningBadge extends StatelessWidget {
  const InningBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 46),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

/// 문자중계 수집 전(`GameSummary.isDetailPending`)에 득점 장면·대타 기용
/// 자리에 두는 카드.
class DetailPendingCard extends StatelessWidget {
  const DetailPendingCard({required this.title, super.key});

  static const message = '세부 기록을 아직 수집하고 있습니다.';

  final String title;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCardTitle(title: title),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              message,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

const summaryMutedTextStyle = TextStyle(
  color: AppColors.textMuted,
  fontSize: 12,
);
