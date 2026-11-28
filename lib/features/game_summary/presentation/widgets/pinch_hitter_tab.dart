import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../domain/entities/game_summary.dart';
import '../../domain/entities/pinch_hitter.dart';
import 'summary_card.dart';

/// 토글 "대타": 팀별 대타 성적과 기용 목록 (정책서 5.8).
class PinchHitterTab extends StatelessWidget {
  const PinchHitterTab({required this.summary, required this.game, super.key});

  final GameSummary summary;
  final GameResult game;

  @override
  Widget build(BuildContext context) {
    final appearances = summary.pinchHitterAppearances;
    final pending = summary.isDetailPending;
    if (!pending && !summary.hasPinchHitters) {
      return const SummaryCard(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Text(
          '대타 기용이 없었습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }

    final cards = <Widget>[
      if (appearances.isNotEmpty || summary.hasPinchHitterStats)
        SummaryCard(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _TeamSummary(
                    summary: summary.homePinchHitterSummary,
                    teamName: game.visibleNameOf(summary.homeTeamCode),
                  ),
                ),
                const VerticalDivider(
                  width: 24,
                  thickness: 1,
                  color: AppColors.surfaceHigh,
                ),
                Expanded(
                  child: _TeamSummary(
                    summary: summary.awayPinchHitterSummary,
                    teamName: game.visibleNameOf(summary.awayTeamCode),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (appearances.isNotEmpty)
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SummaryCardTitle(title: '대타 기용'),
              const SizedBox(height: 4),
              for (var i = 0; i < appearances.length; i++) ...[
                if (i > 0)
                  const Divider(height: 1, color: AppColors.surfaceHigh),
                _AppearanceRow(appearance: appearances[i]),
              ],
            ],
          ),
        )
      // 문자중계 수집 전에는 팀별 성적이 있으면 성적 카드만, 성적도 없으면
      // `대타 기용이 없었습니다.` 대신 수집 중 문구를 보인다 (정책서 5.8).
      else if (pending && !summary.hasPinchHitterStats)
        const DetailPendingCard(title: '대타 기용'),
    ];

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          cards[i],
        ],
      ],
    );
  }
}

class _TeamSummary extends StatelessWidget {
  const _TeamSummary({required this.summary, required this.teamName});

  final PinchHitterSummary summary;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamLogo(teamCode: summary.teamCode, size: 26),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$teamName · ${summary.countLabel}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              // 좁은 기기에서 '1타수 1안타 1타점'이 줄바꿈되지 않게 줄여서 맞춘다.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  summary.lineLabel,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({required this.appearance});

  final PinchHitterAppearance appearance;

  @override
  Widget build(BuildContext context) {
    final result = appearance.resultLabel;
    final good = appearance.isGoodResult;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          InningBadge(appearance.inningText),
          const SizedBox(width: 10),
          TeamLogo(teamCode: appearance.teamCode, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appearance.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (appearance.matchupText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(appearance.matchupText, style: summaryMutedTextStyle),
                ],
              ],
            ),
          ),
          if (result != null) ...[
            const SizedBox(width: 8),
            Text(
              result,
              style: TextStyle(
                color: good ? AppColors.accent : AppColors.textMuted,
                fontSize: 13,
                fontWeight: good ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
