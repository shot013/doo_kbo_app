import 'package:flutter/material.dart';

import '../../domain/entities/standing.dart';

class StandingTable extends StatelessWidget {
  const StandingTable({super.key, required this.standings});

  final List<Standing> standings;

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
          team: const SizedBox.shrink(),
          games: const Text(
            '경기',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          wins: const Text(
            '승',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          losses: const Text(
            '패',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          draws: const Text(
            '무',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          winRate: const Text(
            '승률',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
          gamesBehind: const Text(
            '게임차',
            style: _headerStyle,
            textAlign: TextAlign.center,
          ),
        ),
        const Divider(color: Color(0xFF2C2C2E), height: 24),
        for (final standing in standings) ...[
          _buildRow(
            rank: Text('${standing.rank}', style: _cellStyle),
            team: _TeamBadge(standing: standing),
            games: Text(
              '${standing.gamesPlayed}',
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            wins: Text(
              '${standing.wins}',
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            losses: Text(
              '${standing.losses}',
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            draws: Text(
              '${standing.draws}',
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            winRate: Text(
              standing.winRate,
              style: _cellStyle,
              textAlign: TextAlign.center,
            ),
            gamesBehind: Text(
              standing.gamesBehind ?? '-',
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
    required Widget team,
    required Widget games,
    required Widget wins,
    required Widget losses,
    required Widget draws,
    required Widget winRate,
    required Widget gamesBehind,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: rank),
        Expanded(flex: 5, child: team),
        Expanded(flex: 2, child: games),
        Expanded(flex: 2, child: wins),
        Expanded(flex: 2, child: losses),
        Expanded(flex: 2, child: draws),
        Expanded(flex: 3, child: winRate),
        Expanded(flex: 3, child: gamesBehind),
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.standing});

  final Standing standing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _teamColor(standing.teamCode),
            shape: BoxShape.circle,
          ),
          child: Text(
            standing.teamCode.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            standing.teamName,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _teamColor(String teamCode) {
    return Colors.primaries[teamCode.hashCode % Colors.primaries.length];
  }
}
