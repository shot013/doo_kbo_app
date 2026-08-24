import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/team_logo.dart';
import '../../../player/presentation/screens/player_detail_screen.dart';
import '../../domain/entities/pitcher_record.dart';

class PitcherRecordTable extends StatelessWidget {
  const PitcherRecordTable({super.key, required this.records});

  final List<PitcherRecord> records;

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _cellStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(
          rank: const Text('순위', style: _headerStyle),
          player: const SizedBox.shrink(),
          era: const Text(
            '평균자책',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          wl: const Text(
            '승패',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          saves: const Text(
            '세이브',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(color: AppColors.surfaceHigh, height: 24),
        for (final record in records) ...[
          GestureDetector(
            onTap: () {
              final playerId = record.playerId;
              if (playerId == null) {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surfaceHigh,
                    contentPadding: const EdgeInsets.all(0),
                    content: const Text(
                      '선수 ID가 없습니다',
                      style: TextStyle(
                        color: Color.fromARGB(255, 179, 177, 177),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            color: Color.fromARGB(255, 179, 177, 177),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                return;
              }
              context.pushNamed(
                PlayerDetailScreen.routeName,
                pathParameters: {'id': playerId.toString()},
              );
            },
            child: _buildRow(
              rank: Text('${record.rank}', style: _cellStyle),
              player: _PlayerBadge(
                teamCode: record.teamCode,
                playerName: record.playerName,
                teamName: record.teamName,
              ),
              era: Text(
                record.era,
                style: _cellStyle,
                textAlign: TextAlign.center,
              ),
              wl: Text(
                '${record.wins}승 ${record.losses}패',
                style: _cellStyle,
                textAlign: TextAlign.center,
              ),
              saves: Text(
                '${record.saves}',
                style: _cellStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  static Widget _buildRow({
    required Widget rank,
    required Widget player,
    required Widget era,
    required Widget wl,
    required Widget saves,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: rank),
        Expanded(flex: 6, child: player),
        Expanded(flex: 3, child: era),
        Expanded(flex: 4, child: wl),
        Expanded(flex: 3, child: saves),
      ],
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({
    required this.teamCode,
    required this.playerName,
    required this.teamName,
  });

  final String teamCode;
  final String playerName;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TeamLogo(teamCode: teamCode, size: 24),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                playerName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                teamName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
