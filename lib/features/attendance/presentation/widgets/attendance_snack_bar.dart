import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 직관 체크·해제 뒤의 스낵바. 예: `나의 직관에 추가했어요` [보기]
void showAttendanceSnackBar(
  BuildContext context, {
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceHigh,
        behavior: SnackBarBehavior.floating,
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        action: SnackBarAction(
          label: actionLabel,
          textColor: AppColors.accent,
          onPressed: onAction,
        ),
      ),
    );
}

const attendanceAddedMessage = '나의 직관에 추가했어요';
const attendanceRemovedMessage = '나의 직관에서 뺐어요';
