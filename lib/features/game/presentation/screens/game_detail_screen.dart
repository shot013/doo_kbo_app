import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/game_stat.dart';
import '../../domain/entities/player_stat_type.dart';
import '../providers/game_providers.dart';

class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({required this.gameId, super.key});

  static const routeName = 'gameDetail';
  static const routePath = '/games/:id';

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(gameStatsProvider(gameId));

    return Scaffold(
      appBar: AppBar(title: const Text('박스 스코어')),
      body: statsAsync.when(
        data: (stats) => _BoxScore(stats: stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(error is AppFailure ? error.message : '오류가 발생했습니다.'),
        ),
      ),
    );
  }
}

class _BoxScore extends StatelessWidget {
  const _BoxScore({required this.stats});

  final List<GameStat> stats;

  @override
  Widget build(BuildContext context) {
    final batting = stats
        .where((stat) => stat.statType == PlayerStatType.batting)
        .toList();
    final pitching = stats
        .where((stat) => stat.statType == PlayerStatType.pitching)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('타자', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final stat in batting)
          ListTile(
            title: Text(stat.playerName),
            subtitle: Text(stat.teamCode),
            trailing: Text(
              '${stat.hits ?? 0}/${stat.atBats ?? 0} ${stat.rbi ?? 0}타점',
            ),
          ),
        const SizedBox(height: 16),
        const Text('투수', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final stat in pitching)
          ListTile(
            title: Text(stat.playerName),
            subtitle: Text(stat.teamCode),
            trailing: Text(
              '${stat.inningsPitched ?? '-'}이닝 ERA ${stat.era ?? '-'}',
            ),
          ),
      ],
    );
  }
}
