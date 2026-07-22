import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../game/domain/entities/game.dart';
import '../../../game/domain/entities/game_stat.dart';
import '../../../game/domain/entities/player_stat_type.dart';
import '../../../game/presentation/providers/game_providers.dart';

class RecentGameSection extends ConsumerWidget {
  const RecentGameSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(recentFinishedGamesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 경기 결과',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        gamesAsync.when(
          data: (games) => games.isEmpty
              ? const _RecentGameCardShell(
                  child: Text(
                    '최근 종료된 경기가 없습니다',
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                  ),
                )
              : Column(
                  children: [
                    for (final game in games) ...[
                      _RecentGameCard(game: game),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
          loading: () => const _RecentGameCardShell(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stackTrace) => _RecentGameCardShell(
            child: Text(
              error is AppFailure ? error.message : '최근 경기 정보를 불러오지 못했습니다.',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentGameCardShell extends StatelessWidget {
  const _RecentGameCardShell({required this.child});

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

class _RecentGameCard extends ConsumerWidget {
  const _RecentGameCard({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(gameStatsProvider(game.id));

    return _RecentGameCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${game.awayTeamName} vs ${game.homeTeamName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${game.awayScore} - ${game.homeScore}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          statsAsync.when(
            data: (stats) {
              final best = _findBestBatter(stats);
              if (best == null) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF2C2C2E), height: 1),
                  const SizedBox(height: 16),
                  _BestBatterRow(stat: best),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  GameStat? _findBestBatter(List<GameStat> stats) {
    final batters = stats
        .where((stat) => stat.statType == PlayerStatType.batting)
        .toList();
    if (batters.isEmpty) return null;

    batters.sort((a, b) {
      final scoreA = (a.hits ?? 0) + (a.homeRuns ?? 0) * 2 + (a.rbi ?? 0);
      final scoreB = (b.hits ?? 0) + (b.homeRuns ?? 0) * 2 + (b.rbi ?? 0);
      return scoreB.compareTo(scoreA);
    });
    return batters.first;
  }
}

class _BestBatterRow extends StatelessWidget {
  const _BestBatterRow({required this.stat});

  final GameStat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '베스트 활약',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${stat.playerName} · ${stat.atBats ?? 0}타수 ${stat.hits ?? 0}안타'
            '${(stat.homeRuns ?? 0) > 0 ? '(${stat.homeRuns}홈런)' : ''} '
            '${stat.rbi ?? 0}타점',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
