import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/providers/bottom_nav_provider.dart';
import '../../../../core/providers/stat_tab_provider.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../standing/domain/entities/standing.dart';
import '../../../standing/presentation/providers/standing_providers.dart';

class TeamStandingSection extends ConsumerWidget {
  const TeamStandingSection({super.key});

  static const int _previewCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '팀 순위',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            InkWell(
              onTap: () {
                ref.read(statTabProvider.notifier).select(StatTab.standing);
                ref.read(bottomNavIndexProvider.notifier).select(AppTab.stat);
              },
              child: const Row(
                children: [
                  Text(
                    '더보기',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        standingsAsync.when(
          data: (standings) {
            final preview = standings.take(_previewCount).toList();
            if (preview.isEmpty) {
              return const _StandingCardShell(
                child: Text(
                  '순위 정보가 없습니다',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
              );
            }
            return _StandingCardShell(
              child: Column(
                children: [
                  for (var i = 0; i < preview.length; i++) ...[
                    _StandingRow(standing: preview[i]),
                    if (i != preview.length - 1)
                      const Divider(color: Color(0xFF2C2C2E), height: 24),
                  ],
                ],
              ),
            );
          },
          loading: () => const _StandingCardShell(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stackTrace) => _StandingCardShell(
            child: Text(
              error is AppFailure ? error.message : '순위 정보를 불러오지 못했습니다.',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _StandingCardShell extends StatelessWidget {
  const _StandingCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing});

  final Standing standing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            '${standing.rank}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        TeamLogo(teamCode: standing.teamCode, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            standing.teamName,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '${standing.wins}승 ${standing.losses}패',
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          child: Text(
            standing.winRate,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
