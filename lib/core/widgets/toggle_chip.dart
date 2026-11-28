import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 기록 탭(타자/투수)과 경기 요약(이닝별 득·실점/투수 교체/대타)이 같이 쓰는
/// 토글 칩. 활성은 accent 배경에 onAccent 글자, 비활성은 surfaceHigh 배경.
class ToggleChip extends StatelessWidget {
  const ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.onAccent : AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
