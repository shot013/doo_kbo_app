import 'package:flutter/material.dart';

import '../../../../core/widgets/team_logo.dart';
import '../../domain/entities/batter_record.dart';

class BatterRecordTable extends StatelessWidget {
  const BatterRecordTable({super.key, required this.records});

  final List<BatterRecord> records;

  static const TextStyle _headerStyle = TextStyle(
    color: Color(0xFF9E9E9E),
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _cellStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(
          rank: const Text('순위', style: _headerStyle),
          player: const SizedBox.shrink(),
          avg: const Text(
            '타율',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          homeRuns: const Text(
            '홈런',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          rbi: const Text(
            '타점',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(color: Color(0xFF2C2C2E), height: 24),
        for (final record in records) ...[
          _buildRow(
            rank: Text('${record.rank}', style: _cellStyle),
            player: _PlayerBadge(
              teamCode: record.teamCode,
              playerName: record.playerName,
              teamName: record.teamName,
            ),
            avg: Text(
              record.avg,
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            homeRuns: Text(
              '${record.homeRuns}',
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            rbi: Text(
              '${record.rbi}',
              style: _cellStyle,
              textAlign: TextAlign.center,
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
    required Widget avg,
    required Widget homeRuns,
    required Widget rbi,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: rank),
        Expanded(flex: 6, child: player),
        Expanded(flex: 3, child: avg),
        Expanded(flex: 3, child: homeRuns),
        Expanded(flex: 3, child: rbi),
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                teamName,
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
