import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/player_position.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/providers/favorite_teams_provider.dart';
import '../../../../core/widgets/player_list_row.dart';
import '../../../player/domain/entities/player_summary.dart';
import '../../../player/presentation/screens/player_detail_screen.dart';
import '../../domain/entities/team_detail.dart';
import '../providers/team_providers.dart';

class TeamDetailScreen extends ConsumerWidget {
  const TeamDetailScreen({required this.teamCode, super.key});

  static const routeName = 'teamDetail';
  static const routePath = '/teams/:code';

  final String teamCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(teamDetailProvider(teamCode));
    final favorites = ref.watch(favoriteTeamsProvider);
    final isFavorite = favorites.contains(teamCode);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: detailAsync.maybeWhen(
          data: (detail) => Text(detail.summary.name),
          orElse: () => const Text('팀 상세'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () =>
                ref.read(favoriteTeamsProvider.notifier).toggle(teamCode),
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? const Color(0xFF4ADE80) : Colors.white,
              size: 20,
            ),
            label: Text(
              isFavorite ? '즐겨찾기됨' : '즐겨찾기',
              style: TextStyle(
                color: isFavorite ? const Color(0xFF4ADE80) : Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) => _TeamDetailBody(detail: detail),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              error is AppFailure ? error.message : '팀 정보를 불러오지 못했습니다.',
              style: const TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamDetailBody extends StatelessWidget {
  const _TeamDetailBody({required this.detail});

  final TeamDetail detail;

  @override
  Widget build(BuildContext context) {
    final summary = detail.summary;
    final rosterByPosition = <PlayerPosition, List<PlayerSummary>>{
      for (final position in PlayerPosition.values)
        position: detail.roster.where((p) => p.position == position).toList(),
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 ${summary.rank}위 · ${summary.wins}승 ${summary.losses}패',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '최근 5경기',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final result in summary.recentForm) ...[
                    _ResultBadge(result: result),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '선수단',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        for (final position in PlayerPosition.values) ...[
          if (rosterByPosition[position]!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              position.displayName,
              style: const TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            for (final player in rosterByPosition[position]!)
              PlayerListRow(
                name: player.name,
                teamCode: player.teamCode,
                position: player.position,
                backNumber: player.backNumber,
                trailingText: '기록 보기',
                onTap: () => context.pushNamed(
                  PlayerDetailScreen.routeName,
                  pathParameters: {'id': player.id},
                ),
              ),
          ],
        ],
      ],
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.result});

  final String result;

  @override
  Widget build(BuildContext context) {
    final isWin = result == 'W';
    final isLoss = result == 'L';
    final color = isWin
        ? const Color(0xFF4ADE80)
        : isLoss
        ? const Color(0xFF9E9E9E)
        : Colors.white;

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        result,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
