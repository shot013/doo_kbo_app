import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
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
            color: Colors.white,
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
                    style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
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
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    game.homeTeamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  '  ${game.homeScore} : ${game.awayScore}  ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    game.awayTeamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TeamLogo(teamCode: game.awayTeamCode, size: 40),
            ],
          ),
          if (game.pitchers.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2C2C2E), height: 1),
            const SizedBox(height: 16),
            _PitcherDecisionsRow(pitchers: game.pitchers),
          ],
          if (game.bestPerformer != null) ...[
            const SizedBox(height: 12),
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
      spacing: 12,
      runSpacing: 8,
      children: pitchers
          .map(
            (pitcher) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _decisionLabel(pitcher.decision),
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  pitcher.playerName,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
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
      PitcherDecisionType.save => '세이브',
      PitcherDecisionType.hold => '홀드',
    };
  }
}

class _BestPerformerRow extends StatelessWidget {
  const _BestPerformerRow({required this.bestPerformer});

  final BestPerformer bestPerformer;

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
            '${bestPerformer.playerName} · ${bestPerformer.line}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
