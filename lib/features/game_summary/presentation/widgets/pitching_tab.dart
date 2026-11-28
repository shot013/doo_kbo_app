import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../../game/domain/entities/pitcher_decision_type.dart';
import '../../domain/entities/game_summary.dart';
import '../../domain/entities/pitcher_appearance.dart';
import 'summary_card.dart';

/// 토글 "투수 교체": 팀별 카드를 원정 → 홈 순서로 (정책서 5.8).
class PitchingTab extends StatelessWidget {
  const PitchingTab({required this.summary, required this.game, super.key});

  final GameSummary summary;
  final GameResult game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PitchingTeamCard(
          teamCode: summary.awayTeamCode,
          teamName: game.visibleNameOf(summary.awayTeamCode),
          pitchers: summary.awayPitchers,
          summary: summary,
        ),
        const SizedBox(height: 16),
        PitchingTeamCard(
          teamCode: summary.homeTeamCode,
          teamName: game.visibleNameOf(summary.homeTeamCode),
          pitchers: summary.homePitchers,
          summary: summary,
        ),
      ],
    );
  }
}

class PitchingTeamCard extends StatelessWidget {
  const PitchingTeamCard({
    required this.teamCode,
    required this.teamName,
    required this.pitchers,
    required this.summary,
    super.key,
  });

  final String teamCode;
  final String teamName;
  final List<PitcherAppearance> pitchers;
  final GameSummary summary;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCardTitle(
            title: '$teamName 투수',
            leading: TeamLogo(teamCode: teamCode, size: 20),
            trailing: Text(
              '${pitchers.length}명 등판',
              style: summaryMutedTextStyle,
            ),
          ),
          if (pitchers.isNotEmpty) ...[
            const SizedBox(height: 12),
            _OutsBar(
              pitchers: pitchers,
              inningCount: summary.lineScore.inningCount,
              totalOuts: summary.totalOutsSlots,
            ),
            const SizedBox(height: 12),
            _PitcherTable(
              pitchers: pitchers,
              showsPitchCount: summary.showsPitchCount,
              showsRuns: summary.showsRuns,
            ),
          ],
        ],
      ),
    );
  }
}

/// 아웃카운트 비율 막대. 투수별 구간 길이 = 잡은 아웃 수, 교체 지점에 accent
/// 세로선, 던지지 않은 칸(9회말 미진행 등)은 "—".
class _OutsBar extends StatelessWidget {
  const _OutsBar({
    required this.pitchers,
    required this.inningCount,
    required this.totalOuts,
  });

  final List<PitcherAppearance> pitchers;
  final int inningCount;
  final int totalOuts;

  static const double _barHeight = 22;

  @override
  Widget build(BuildContext context) {
    final pitchedOuts = pitchers.fold(0, (sum, p) => sum + p.outs);
    final remaining = totalOuts - pitchedOuts;

    final segments = <Widget>[];
    for (var i = 0; i < pitchers.length; i++) {
      final pitcher = pitchers[i];
      if (i > 0) {
        segments.add(
          Container(
            key: ValueKey('pitching-change-marker-$i'),
            width: 2,
            height: _barHeight + 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }
      if (pitcher.outs <= 0) continue;
      segments.add(
        Expanded(
          flex: pitcher.outs,
          child: Container(
            height: _barHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i.isEven ? AppColors.border : AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(6),
            ),
            child: _FittingName(pitcher.playerName),
          ),
        ),
      );
    }
    if (remaining > 0) {
      segments.add(
        Expanded(
          flex: remaining,
          child: const Text(
            '—',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (var inning = 1; inning <= inningCount; inning++)
              Expanded(
                child: Text(
                  '$inning',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: _barHeight + 8,
          child: Row(children: segments),
        ),
      ],
    );
  }
}

/// 막대 안의 투수 이름. 짧게 던진 투수는 칸이 좁아 이름이 잘려 보이므로
/// (`우규`, `주`), 다 들어가지 않으면 비워 둔다. 이름은 아래 표에 모두 있다.
class _FittingName extends StatelessWidget {
  const _FittingName(this.name);

  final String name;

  static const _style = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: name, style: _style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final fits = painter.width <= constraints.maxWidth - 4;
        painter.dispose();
        if (!fits) return const SizedBox.shrink();
        return Text(name, maxLines: 1, style: _style);
      },
    );
  }
}

class _PitcherTable extends StatelessWidget {
  const _PitcherTable({
    required this.pitchers,
    required this.showsPitchCount,
    required this.showsRuns,
  });

  final List<PitcherAppearance> pitchers;
  final bool showsPitchCount;
  final bool showsRuns;

  static const double _nameWidth = 64;
  static const double _numberWidth = 34;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              width: _nameWidth,
              child: Text('투수', style: _headerStyle),
            ),
            const Expanded(child: Text('교체 시점', style: _headerStyle)),
            _number('이닝', _headerStyle),
            if (showsPitchCount) _number('투구', _headerStyle),
            if (showsRuns) _number('실점', _headerStyle),
            _number('결정', _headerStyle),
          ],
        ),
        for (final pitcher in pitchers)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                SizedBox(
                  width: _nameWidth,
                  child: Text(
                    pitcher.playerName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    pitcher.entryLabel,
                    style: TextStyle(
                      color: pitcher.highlightsEntry
                          ? AppColors.accent
                          : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: pitcher.highlightsEntry
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
                _number(pitcher.inningsPitchedLabel, _valueStyle),
                if (showsPitchCount)
                  _number(pitcher.pitchCountLabel, _valueStyle),
                if (showsRuns) _number(pitcher.runsLabel, _valueStyle),
                SizedBox(
                  width: _numberWidth,
                  child: Center(child: _DecisionBadge(pitcher: pitcher)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static const _headerStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  static const _valueStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
  );

  static Widget _number(String text, TextStyle style) => SizedBox(
    width: _numberWidth,
    child: Text(text, textAlign: TextAlign.center, style: style),
  );
}

/// 승·패·세·홀 원형 배지. 승만 accent, 나머지는 textMuted.
class _DecisionBadge extends StatelessWidget {
  const _DecisionBadge({required this.pitcher});

  final PitcherAppearance pitcher;

  @override
  Widget build(BuildContext context) {
    final label = pitcher.decisionLabel;
    if (label == null) return const SizedBox(height: 24);
    final color = pitcher.decision == PitcherDecisionType.win
        ? AppColors.accent
        : AppColors.textMuted;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
