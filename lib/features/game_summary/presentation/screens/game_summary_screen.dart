import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../../core/widgets/toggle_chip.dart';
import '../../../attendance/presentation/widgets/attend_game_button.dart';
import '../../../favorite_team/presentation/providers/favorite_team_providers.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../../game/presentation/providers/game_providers.dart';
import '../../domain/entities/game_summary.dart';
import '../../domain/entities/summary_game_list.dart';
import '../providers/game_summary_providers.dart';
import '../widgets/pinch_hitter_tab.dart';
import '../widgets/pitching_tab.dart';
import '../widgets/runs_tab.dart';
import '../widgets/summary_card.dart';

/// 경기 요약 (정책서 5.8). HOME 빈 카드 버튼과 최근 경기 결과 카드에서는 최근
/// 경기일로, 나의 직관 목록에서는 [date]로 연다.
class GameSummaryScreen extends ConsumerWidget {
  const GameSummaryScreen({this.initialGameId, this.date, super.key});

  static const routeName = 'gameSummary';
  static const routePath = '/game-summary';

  /// 처음 선택할 경기. 최근 경기 결과 카드에서 열면 그 경기, 빈 카드
  /// 버튼에서 열면 null(MY팀 경기 → 첫 경기).
  final String? initialGameId;

  /// 경기 칩을 보일 날짜 `YYYY-MM-DD`. null이면 최근 경기일.
  final String? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = this.date;
    final resultsAsync = date == null
        ? ref.watch(recentGameResultsProvider)
        : ref.watch(gameResultsOnDateProvider(date));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('경기 요약')),
      body: resultsAsync.when(
        data: (games) => games.isEmpty
            ? _CenteredMessage(
                date == null ? '최근 종료된 경기가 없습니다' : '이 날 종료된 경기가 없습니다',
              )
            : _SummaryBody(
                games: games,
                initialGameId: initialGameId,
                isRecent: date == null,
              ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
        error: (error, stackTrace) => _CenteredMessage(
          error is AppFailure ? error.message : '최근 경기 정보를 불러오지 못했습니다.',
        ),
      ),
    );
  }
}

class _SummaryBody extends ConsumerWidget {
  const _SummaryBody({
    required this.games,
    required this.initialGameId,
    required this.isRecent,
  });

  final List<GameResult> games;
  final String? initialGameId;
  final bool isRecent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteTeamCode = ref.watch(favoriteTeamCodeProvider).value;
    final gameList = SummaryGameList(
      games,
      favoriteTeamCode: favoriteTeamCode,
      isRecent: isRecent,
    );
    final selectedId = ref.watch(selectedSummaryGameIdProvider);
    final game = gameList.select(selectedId ?? initialGameId)!;
    // 요약이 없는 경기(404)로 바꾸면 토글이 사라져도, 다른 경기로 돌아왔을 때
    // 보던 토글을 유지하도록 화면이 떠 있는 동안 토글 상태를 붙잡아 둔다.
    ref.listen(gameSummaryTabProvider, (_, _) {});

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          gameList.dateLabel,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 10),
        _GameChips(gameList: gameList, selected: game),
        const SizedBox(height: 16),
        _ScoreCard(game: game),
        const SizedBox(height: 12),
        AttendGameButton(game: game),
        const SizedBox(height: 16),
        _SummarySection(game: game),
      ],
    );
  }
}

class _GameChips extends ConsumerWidget {
  const _GameChips({required this.gameList, required this.selected});

  final SummaryGameList gameList;
  final GameResult selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: gameList.games.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final game = gameList.games[index];
          final isSelected = game.gameId == selected.gameId;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => ref
                .read(selectedSummaryGameIdProvider.notifier)
                .select(game.gameId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.16)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  width: 1.5,
                ),
              ),
              child: Text(
                gameList.chipLabel(game),
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 점수 카드. 기존 최근 경기 결과 데이터로 그려서, 요약을 받지 못해도 보인다.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.game});

  final GameResult game;

  @override
  Widget build(BuildContext context) {
    final stadium = game.stadium;
    return SummaryCard(
      child: Column(
        children: [
          Text(
            stadium == null || stadium.isEmpty ? '경기 종료' : '$stadium · 경기 종료',
            style: summaryMutedTextStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TeamLogo(teamCode: game.homeTeamCode, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: _TeamName(
                  name: game.homeTeamVisibleName,
                  decision: game.winLossPitcherLabel(game.homeTeamCode),
                  alignEnd: false,
                ),
              ),
              Text(
                '${game.homeScore} : ${game.awayScore}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: _TeamName(
                  name: game.awayTeamVisibleName,
                  decision: game.winLossPitcherLabel(game.awayTeamCode),
                  alignEnd: true,
                ),
              ),
              const SizedBox(width: 8),
              TeamLogo(teamCode: game.awayTeamCode, size: 40),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamName extends StatelessWidget {
  const _TeamName({
    required this.name,
    required this.decision,
    required this.alignEnd,
  });

  final String name;
  final String? decision;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (decision != null) ...[
          const SizedBox(height: 2),
          Text(decision!, style: summaryMutedTextStyle),
        ],
      ],
    );
  }
}

/// 토글과 요약 영역. 점수 카드와 따로 그려, 요약 요청이 실패해도 점수 카드는
/// 그대로 보인다. 요약이 없으면(404) 토글을 숨기고 문구만 보인다.
class _SummarySection extends ConsumerWidget {
  const _SummarySection({required this.game});

  final GameResult game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(gameSummaryProvider(game.gameId));

    return summaryAsync.when(
      data: (summary) => _SummaryTabs(summary: summary, game: game),
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Text(
          error is NotFoundFailure
              ? '아직 이 경기의 요약 정보가 없습니다.'
              : error is AppFailure
              ? error.message
              : '요약 정보를 불러오지 못했습니다.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ),
    );
  }
}

class _SummaryTabs extends ConsumerWidget {
  const _SummaryTabs({required this.summary, required this.game});

  final GameSummary summary;
  final GameResult game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(gameSummaryTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in GameSummaryTab.values)
              ToggleChip(
                label: option.label,
                active: option == tab,
                onTap: () =>
                    ref.read(gameSummaryTabProvider.notifier).select(option),
              ),
          ],
        ),
        const SizedBox(height: 16),
        switch (tab) {
          GameSummaryTab.runs => RunsTab(summary: summary, game: game),
          GameSummaryTab.pitching => PitchingTab(summary: summary, game: game),
          GameSummaryTab.pinchHitters => PinchHitterTab(
            summary: summary,
            game: game,
          ),
        },
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ),
    );
  }
}
