import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_preview.dart';
import '../providers/game_providers.dart';

class GamePreviewScreen extends ConsumerWidget {
  const GamePreviewScreen({required this.gameId, this.game, super.key});

  static const routeName = 'gamePreview';
  static const routePath = '/games/:id/preview';

  final String gameId;

  /// "오늘의 경기" 카드에서 넘어올 때 이미 갖고 있던 팀 정보를 그대로 받아
  /// 헤더에 표시한다. 딥링크 등으로 이 값 없이 접근하면 헤더 없이 통계만 보여준다.
  final Game? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewAsync = ref.watch(gamePreviewProvider(gameId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('경기 프리뷰')),
      body: previewAsync.when(
        data: (preview) => _GamePreviewBody(preview: preview, game: game),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is NotFoundFailure
                  ? '아직 이 경기의 프리뷰 정보가 없습니다.'
                  : error is AppFailure
                  ? error.message
                  : '프리뷰 정보를 불러오지 못했습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _GamePreviewBody extends StatelessWidget {
  const _GamePreviewBody({required this.preview, required this.game});

  final GamePreview preview;
  final Game? game;

  @override
  Widget build(BuildContext context) {
    final homeLabel = game?.homeTeamVisibleName ?? '홈';
    final awayLabel = game?.awayTeamVisibleName ?? '원정';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (game != null) _MatchupHeader(game: game!),
        if (game != null) const SizedBox(height: 20),
        _ComparisonTable(
          title: '팀 전력비교',
          homeLabel: homeLabel,
          awayLabel: awayLabel,
          rows: [
            (
              label: '최근 성적',
              home: preview.homeTeam.record,
              away: preview.awayTeam.record,
            ),
            (
              label: '최근 5경기',
              home: preview.homeTeam.recentForm,
              away: preview.awayTeam.recentForm,
            ),
            (
              label: '팀 평균자책',
              home: preview.homeTeam.era,
              away: preview.awayTeam.era,
            ),
            (
              label: '팀 타율',
              home: preview.homeTeam.battingAverage,
              away: preview.awayTeam.battingAverage,
            ),
            (
              label: '경기당 득점',
              home: preview.homeTeam.avgRunsScored,
              away: preview.awayTeam.avgRunsScored,
            ),
            (
              label: '경기당 실점',
              home: preview.homeTeam.avgRunsAllowed,
              away: preview.awayTeam.avgRunsAllowed,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ComparisonTable(
          title: '선발투수 매치업',
          homeLabel: homeLabel,
          awayLabel: awayLabel,
          rows: [
            (
              label: '구질',
              home: preview.homePitcher.style,
              away: preview.awayPitcher.style,
            ),
            (
              label: '시즌 성적',
              home: preview.homePitcher.seasonRecord,
              away: preview.awayPitcher.seasonRecord,
            ),
            (
              label: '상대 전적',
              home: preview.homePitcher.headToHeadRecord,
              away: preview.awayPitcher.headToHeadRecord,
            ),
            (
              label: '평균자책',
              home: preview.homePitcher.era,
              away: preview.awayPitcher.era,
            ),
            (
              label: 'WAR',
              home: preview.homePitcher.war,
              away: preview.awayPitcher.war,
            ),
            (
              label: '등판 경기',
              home: preview.homePitcher.games,
              away: preview.awayPitcher.games,
            ),
            (
              label: '평균 이닝',
              home: preview.homePitcher.avgInnings,
              away: preview.awayPitcher.avgInnings,
            ),
            (
              label: '퀄리티스타트',
              home: preview.homePitcher.qualityStarts,
              away: preview.awayPitcher.qualityStarts,
            ),
            (
              label: 'WHIP',
              home: preview.homePitcher.whip,
              away: preview.awayPitcher.whip,
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchupHeader extends StatelessWidget {
  const _MatchupHeader({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TeamHeader(
            code: game.homeTeamCode,
            label: game.homeTeamVisibleName,
          ),
        ),
        const Text(
          'VS',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: _TeamHeader(
            code: game.awayTeamCode,
            label: game.awayTeamVisibleName,
          ),
        ),
      ],
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.code, required this.label});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamLogo(teamCode: code, size: 44),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

typedef _ComparisonRow = ({String label, String? home, String? away});

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.title,
    required this.homeLabel,
    required this.awayLabel,
    required this.rows,
  });

  final String title;
  final String homeLabel;
  final String awayLabel;
  final List<_ComparisonRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  homeLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
              Expanded(
                child: Text(
                  awayLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.home ?? '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.away ?? '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
