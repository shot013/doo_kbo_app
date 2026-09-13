import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../team/domain/entities/team_summary.dart';
import '../../../team/presentation/providers/team_providers.dart';
import '../providers/favorite_team_providers.dart';

/// 즐겨찾기 팀을 고르는 bottom sheet. 팀을 탭하면 바로 저장하고 닫힌다.
///
/// `MainShell`이 탭마다 독립된 Navigator를 쓰는 `StatefulShellRoute`라서,
/// `useRootNavigator: true` 없이 열면 이 시트가 탭 내부 Navigator에 붙어
/// 바깥 Scaffold의 하단 내비게이션 바보다 아래 레이어에 그려진다.
Future<void> showFavoriteTeamPicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _FavoriteTeamPickerSheet(),
  );
}

class _FavoriteTeamPickerSheet extends ConsumerWidget {
  const _FavoriteTeamPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamListProvider);
    final favoriteTeamCode = ref.watch(favoriteTeamCodeProvider).value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '즐겨찾기 팀 설정',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            teamsAsync.when(
              data: (teams) =>
                  _TeamGrid(teams: teams, favoriteTeamCode: favoriteTeamCode),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              error: (error, stackTrace) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    '팀 정보를 불러오지 못했습니다.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ),
            if (favoriteTeamCode != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(favoriteTeamCodeProvider.notifier)
                        .select(null);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    '즐겨찾기 해제',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamGrid extends ConsumerWidget {
  const _TeamGrid({required this.teams, required this.favoriteTeamCode});

  final List<TeamSummary> teams;
  final String? favoriteTeamCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teams.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // 로고 + 팀 코드 텍스트가 정사각형 셀(childAspectRatio 기본값 1.0)에는
        // 6px 넘게 넘쳐서(디버그 모드에서 렌더 오버플로우로 확인됨) 셀을 조금 더
        // 세로로 넉넉하게 잡는다.
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final team = teams[index];
        final isSelected = team.teamCode == favoriteTeamCode;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await ref
                .read(favoriteTeamCodeProvider.notifier)
                .select(team.teamCode);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.16)
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: AppColors.accent, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TeamLogo(teamCode: team.teamCode, size: 36),
                const SizedBox(height: 6),
                Text(
                  team.teamCode,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
