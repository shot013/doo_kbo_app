import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../favorite_team/presentation/providers/favorite_team_providers.dart';
import '../../../favorite_team/presentation/widgets/favorite_team_picker_sheet.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(36);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leadingWidth: 50,
      titleSpacing: 0,
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.gold,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.sports_baseball,
          color: AppColors.onAccent,
          size: 20,
        ),
      ),
      title: const Text(
        '직관',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          height: 1.0,
        ),
      ),
      actions: const [_FavoriteTeamBadge(), SizedBox(width: 16)],
    );
  }
}

/// 현재 즐겨찾기 중인 팀을 앱바 우측에 로고로 보여준다. 탭하면 즐겨찾기
/// 팀 설정 시트가 열려, 어느 탭에서든 바로 바꿀 수 있다. 즐겨찾기 팀이
/// 없으면 아무것도 표시하지 않는다.
class _FavoriteTeamBadge extends ConsumerWidget {
  const _FavoriteTeamBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteTeamCode = ref.watch(favoriteTeamCodeProvider).value;
    if (favoriteTeamCode == null) {
      return const SizedBox.shrink();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => showFavoriteTeamPicker(context),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TeamLogo(teamCode: favoriteTeamCode, size: 24),
            const SizedBox(width: 4),
            Text(
              favoriteTeamCode,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
