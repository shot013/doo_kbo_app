import 'package:flutter/material.dart';

import '../constants/player_position.dart';
import '../theme/app_colors.dart';
import 'team_logo.dart';

/// `player`(선수 탭 목록)와 `team`(팀 상세 로스터)에서 공용으로 쓰는 선수 리스트 행.
class PlayerListRow extends StatelessWidget {
  const PlayerListRow({
    required this.name,
    required this.teamCode,
    required this.position,
    required this.backNumber,
    required this.trailingText,
    this.subtitle,
    this.showTeamLogo = false,
    this.onTap,
    super.key,
  });

  final String name;
  final String teamCode;
  final PlayerPosition position;
  final int backNumber;
  final String trailingText;
  final String? subtitle;
  final bool showTeamLogo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (showTeamLogo)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TeamLogo(teamCode: teamCode, size: 36),
              )
            else
              _BackNumberBadge(backNumber: backNumber),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? position.displayName,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailingText,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackNumberBadge extends StatelessWidget {
  const _BackNumberBadge({required this.backNumber});

  final int backNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.border,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$backNumber',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
