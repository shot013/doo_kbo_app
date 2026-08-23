import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/bottom_nav_spacer.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../domain/entities/team_summary.dart';
import '../providers/team_providers.dart';
import 'team_detail_screen.dart';

class TeamSection extends ConsumerWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamListProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          teamsAsync.when(
            data: (teams) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: [for (final team in teams) _TeamCard(team: team)],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  error is AppFailure ? error.message : '팀 정보를 불러오지 못했습니다.',
                  style: const TextStyle(color: Color(0xFF9E9E9E)),
                ),
              ),
            ),
          ),
          const BottomNavSpacer(),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});

  final TeamSummary team;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.pushNamed(
        TeamDetailScreen.routeName,
        pathParameters: {'code': team.code},
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            TeamLogo(teamCode: team.code, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${team.rank}위 · ${team.wins}승 ${team.losses}패 ${team.draws}무',
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TeamStat(label: '타율', value: team.battingAverage),
                      _TeamStat(label: '평균자책', value: team.era),
                      _TeamStat(label: '득점', value: '${team.runsScored}'),
                      _TeamStat(label: '실점', value: '${team.runsAllowed}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamStat extends StatelessWidget {
  const _TeamStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
