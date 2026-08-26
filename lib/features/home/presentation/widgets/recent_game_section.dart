import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../game/domain/entities/best_performer.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../../game/domain/entities/pitcher_decision.dart';
import '../../../game/domain/entities/pitcher_decision_type.dart';
import '../../../game/presentation/providers/game_providers.dart';

class RecentGameSection extends ConsumerWidget {
  const RecentGameSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(recentGameResultsProvider);
    final games = resultsAsync.value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 경기 결과${games.isEmpty ? '' : ' ${games.first.gameDate}'}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        resultsAsync.when(
          data: (games) => games.isEmpty
              ? const _RecentGameCardShell(
                  child: Text(
                    '최근 종료된 경기가 없습니다',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                )
              : Column(
                  children: games
                      .map(
                        (game) => Column(
                          children: [
                            _RecentGameCard(game: game),
                            const SizedBox(height: 16),
                          ],
                        ),
                      )
                      .toList(),
                ),
          loading: () => const _RecentGameCardShell(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.textPrimary),
            ),
          ),
          error: (error, stackTrace) => _RecentGameCardShell(
            child: Text(
              error is AppFailure ? error.message : '최근 경기 정보를 불러오지 못했습니다.',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _RecentGameCard extends StatelessWidget {
  const _RecentGameCard({required this.game});

  final GameResult game;

  @override
  Widget build(BuildContext context) {
    return _RecentGameCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TeamLogo(teamCode: game.homeTeamCode, size: 40),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        game.homeTeamVisibleName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (game
                        .getPitchersByTeam(game.homeTeamCode)
                        .isNotEmpty) ...[
                      Container(
                        alignment: Alignment.centerRight,
                        child: _PitcherDecisionsRow(
                          pitchers: game.getPitchersByTeam(game.homeTeamCode),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '  ${game.homeScore} : ${game.awayScore}  ',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        game.awayTeamVisibleName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (game
                        .getPitchersByTeam(game.awayTeamCode)
                        .isNotEmpty) ...[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: _PitcherDecisionsRow(
                          pitchers: game.getPitchersByTeam(game.awayTeamCode),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              TeamLogo(teamCode: game.awayTeamCode, size: 40),
            ],
          ),
          if (game.bestPerformer != null) ...[
            const SizedBox(height: 20),
            _BestPerformerRow(bestPerformer: game.bestPerformer!),
          ],
        ],
      ),
    );
  }
}

class _PitcherDecisionsRow extends StatelessWidget {
  const _PitcherDecisionsRow({required this.pitchers});

  final List<PitcherDecision> pitchers;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: pitchers
          .map(
            (pitcher) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _decisionLabel(pitcher.decision),
                  style: TextStyle(
                    color: _decisionColor(pitcher.decision),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  pitcher.playerName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  String _decisionLabel(PitcherDecisionType decision) {
    return switch (decision) {
      PitcherDecisionType.win => '승',
      PitcherDecisionType.loss => '패',
      PitcherDecisionType.save => '세',
      PitcherDecisionType.hold => '홀',
    };
  }

  Color _decisionColor(PitcherDecisionType decision) {
    return switch (decision) {
      PitcherDecisionType.win => const Color.fromARGB(255, 126, 152, 223),
      PitcherDecisionType.loss => const Color.fromARGB(255, 161, 88, 88),
      PitcherDecisionType.save => const Color.fromARGB(255, 101, 139, 111),
      PitcherDecisionType.hold => const Color.fromARGB(255, 115, 208, 224),
    };
  }
}

class _BestPerformerRow extends StatelessWidget {
  const _BestPerformerRow({required this.bestPerformer});

  final BestPerformer bestPerformer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '베스트 활약',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${bestPerformer.playerName} · ${bestPerformer.line}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
