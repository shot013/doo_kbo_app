import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../game/domain/entities/game_result.dart';
import '../../domain/entities/game_summary.dart';
import '../../domain/entities/line_score.dart';
import '../../domain/entities/scoring_play.dart';
import 'summary_card.dart';

/// 토글 "이닝별 득·실점": 점수표, 이닝별 득점 흐름, 득점 장면 (정책서 5.8).
class RunsTab extends StatelessWidget {
  const RunsTab({required this.summary, required this.game, super.key});

  final GameSummary summary;
  final GameResult game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LineScoreTable(lineScore: summary.lineScore, game: game),
        const SizedBox(height: 16),
        InningRunsChart(lineScore: summary.lineScore, game: game),
        if (summary.isDetailPending) ...[
          const SizedBox(height: 16),
          const DetailPendingCard(title: '득점 장면'),
        ] else if (summary.scoringPlays.isNotEmpty) ...[
          const SizedBox(height: 16),
          ScoringPlaysCard(plays: summary.scoringPlays),
        ],
      ],
    );
  }
}

/// 점수표. 원정 위·홈 아래, 이닝 열은 연장이면 가로로 넘긴다.
class LineScoreTable extends StatelessWidget {
  const LineScoreTable({
    required this.lineScore,
    required this.game,
    super.key,
  });

  final LineScore lineScore;
  final GameResult game;

  // 360dp 폭 기기에서도 9이닝이 한 화면에 들어가는 크기. 연장이면 가로로 넘긴다.
  static const double _rowHeight = 32;
  static const double _minInningWidth = 16;
  static const double _totalWidth = 22;
  static const double _teamWidth = 56;

  @override
  Widget build(BuildContext context) {
    final teams = [lineScore.away, lineScore.home];
    final winner = lineScore.winnerTeamCode;
    final count = lineScore.inningCount;

    return SummaryCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _teamWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerRow(const []),
                for (final team in teams)
                  SizedBox(
                    height: _rowHeight,
                    child: Row(
                      children: [
                        TeamLogo(teamCode: team.teamCode, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            game.visibleNameOf(team.teamCode),
                            overflow: TextOverflow.ellipsis,
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
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = math.max(
                  _minInningWidth,
                  constraints.maxWidth / count,
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      _headerRow([
                        for (final header in lineScore.inningHeaders)
                          _cell(header, cellWidth, _headerStyle),
                      ]),
                      for (final team in teams)
                        _row([
                          for (final value in team.inningCells(count))
                            _cell(value, cellWidth, _inningStyle(value)),
                        ]),
                    ],
                  ),
                );
              },
            ),
          ),
          Column(
            children: [
              _headerRow([
                _cell(
                  'R',
                  _totalWidth,
                  _headerStyle.copyWith(fontWeight: FontWeight.w700),
                ),
                for (final header in const ['H', 'E', 'B'])
                  _cell(header, _totalWidth, _headerStyle),
              ]),
              for (final team in teams)
                _row([
                  _cell(
                    '${team.runs}',
                    _totalWidth,
                    TextStyle(
                      color: team.teamCode == winner
                          ? AppColors.accent
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  for (final value in [team.hits, team.errors, team.walks])
                    _cell('$value', _totalWidth, _totalStyle),
                ]),
            ],
          ),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const _totalStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
  );

  static TextStyle _inningStyle(String value) {
    final scored = int.tryParse(value) ?? 0;
    return TextStyle(
      color: scored > 0 ? AppColors.textPrimary : AppColors.textMuted,
      fontSize: 13,
      fontWeight: scored > 0 ? FontWeight.w700 : FontWeight.w400,
    );
  }

  static Widget _row(List<Widget> cells) => SizedBox(
    height: _rowHeight,
    child: Row(children: cells),
  );

  /// 머리글 행. 아래 구분선이 팀 열부터 B 열까지 이어진다.
  static Widget _headerRow(List<Widget> cells) => Container(
    height: _rowHeight,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.surfaceHigh)),
    ),
    child: Row(children: cells),
  );

  static Widget _cell(String text, double width, TextStyle style) => SizedBox(
    width: width,
    child: Text(text, textAlign: TextAlign.center, style: style),
  );
}

/// 이닝별 득점 흐름. 이긴 팀은 가운데 축 위 accent 막대, 진 팀은 아래 textMuted
/// 막대. 무승부면 홈팀을 위에 두고 두 팀 모두 textMuted.
class InningRunsChart extends StatelessWidget {
  const InningRunsChart({
    required this.lineScore,
    required this.game,
    super.key,
  });

  final LineScore lineScore;
  final GameResult game;

  static const double _maxBarHeight = 52;
  static const double _labelHeight = 18;
  static const double _barWidth = 14;

  @override
  Widget build(BuildContext context) {
    final draw = lineScore.isDraw;
    final homeOnTop =
        draw || lineScore.winnerTeamCode == lineScore.home.teamCode;
    final top = homeOnTop ? lineScore.home : lineScore.away;
    final bottom = homeOnTop ? lineScore.away : lineScore.home;
    final topColor = draw ? AppColors.textMuted : AppColors.accent;
    const bottomColor = AppColors.textMuted;

    final count = lineScore.inningCount;
    final innings = [for (var i = 1; i <= count; i++) i];
    final maxRuns = [
      for (final inning in innings) ...[
        top.runsInInning(inning),
        bottom.runsInInning(inning),
      ],
    ].fold(1, math.max);
    final unit = _maxBarHeight / math.max(maxRuns, 3);
    const halfHeight = _maxBarHeight + _labelHeight;

    return SummaryCard(
      child: Column(
        children: [
          SummaryCardTitle(
            title: '이닝별 득점 흐름',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendItem(
                  color: topColor,
                  label: game.visibleNameOf(top.teamCode),
                ),
                const SizedBox(width: 10),
                _LegendItem(
                  color: bottomColor,
                  label: game.visibleNameOf(bottom.teamCode),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final inning in innings)
                Expanded(
                  child: SizedBox(
                    height: halfHeight,
                    child: _Bar(
                      runs: top.runsInInning(inning),
                      unit: unit,
                      color: topColor,
                      up: true,
                    ),
                  ),
                ),
            ],
          ),
          Container(height: 1, color: AppColors.border),
          Row(
            children: [
              for (final inning in innings)
                Expanded(
                  child: SizedBox(
                    height: halfHeight,
                    child: _Bar(
                      runs: bottom.runsInInning(inning),
                      unit: unit,
                      color: bottomColor,
                      up: false,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final inning in innings)
                Expanded(
                  child: Text(
                    '$inning회',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.runs,
    required this.unit,
    required this.color,
    required this.up,
  });

  final int runs;
  final double unit;
  final Color color;
  final bool up;

  @override
  Widget build(BuildContext context) {
    if (runs <= 0) return const SizedBox.shrink();
    const radius = Radius.circular(4);
    final bar = Container(
      width: InningRunsChart._barWidth,
      height: runs * unit,
      decoration: BoxDecoration(
        color: color,
        borderRadius: up
            ? const BorderRadius.vertical(top: radius)
            : const BorderRadius.vertical(bottom: radius),
      ),
    );
    final label = Text(
      '$runs',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
    );
    return Column(
      mainAxisAlignment: up ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: up ? [label, bar] : [bar, label],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: summaryMutedTextStyle),
      ],
    );
  }
}

/// 득점 장면 목록. 점수가 난 순서대로 `이닝 | 팀 로고 | 설명 | 그 뒤 점수(홈:원정)`.
class ScoringPlaysCard extends StatelessWidget {
  const ScoringPlaysCard({required this.plays, super.key});

  final List<ScoringPlay> plays;

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SummaryCardTitle(title: '득점 장면'),
          const SizedBox(height: 8),
          for (final play in plays)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  InningBadge(play.inningText),
                  const SizedBox(width: 10),
                  TeamLogo(teamCode: play.teamCode, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      play.descriptionText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    play.scoreText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
