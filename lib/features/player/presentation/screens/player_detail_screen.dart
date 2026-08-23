import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/player_position.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../domain/entities/player_detail.dart';
import '../../domain/entities/player_stat_line.dart';
import '../../domain/entities/player_vs_team_stat.dart';
import '../providers/player_providers.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({required this.playerId, super.key});

  static const routeName = 'playerDetail';
  static const routePath = '/players/:id';

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(playerDetailProvider(playerId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: detailAsync.maybeWhen(
          data: (player) => Text(player.name),
          orElse: () => const Text('선수 상세'),
        ),
      ),
      body: SafeArea(
        child: detailAsync.when(
          data: (player) => _PlayerDetailBody(player: player),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              error is AppFailure ? error.message : '선수 정보를 불러오지 못했습니다.',
              style: const TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerDetailBody extends StatelessWidget {
  const _PlayerDetailBody({required this.player});

  final PlayerDetail player;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            TeamLogo(teamCode: player.teamCode, size: 48),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.teamName} · ${player.position.displayName} · No.${player.backNumber}',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (final line in player.statLines) ...[
                _StatRow(line: line),
                if (line != player.statLines.last)
                  const Divider(color: Color(0xFF2C2C2E), height: 20),
              ],
            ],
          ),
        ),
        if (player.vsTeamStats.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            player.position == PlayerPosition.pitcher ? '구단별 피안타율' : '구단별 안타율',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (final stat in player.vsTeamStats) ...[
                  _VsTeamStatRow(stat: stat),
                  if (stat != player.vsTeamStats.last)
                    const Divider(color: Color(0xFF2C2C2E), height: 20),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.line});

  final PlayerStatLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          line.label,
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        ),
        Text(
          line.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VsTeamStatRow extends StatelessWidget {
  const _VsTeamStatRow({required this.stat});

  final PlayerVsTeamStat stat;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TeamLogo(teamCode: stat.teamCode, size: 24),
            const SizedBox(width: 8),
            Text(
              stat.teamName,
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ],
        ),
        Text(
          '${stat.avg} · ${stat.games}경기',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
