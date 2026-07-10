import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AllStarRecord extends Equatable {
  const AllStarRecord({
    required this.season,
    required this.player,
    required this.team,
    required this.record,
  });

  final String season;
  final String player;
  final String team;
  final String record;

  @override
  List<Object?> get props => [season, player, team, record];
}

class AllStarSection extends StatelessWidget {
  const AllStarSection({super.key});

  static const List<AllStarRecord> _records = [
    AllStarRecord(
      season: '2025',
      player: '박동원',
      team: 'LG 트윈스',
      record: '4타수 3안타(1홈런)\n3타점 1득점',
    ),
    AllStarRecord(
      season: '2024',
      player: '최형우',
      team: 'KIA 타이거즈',
      record: '4타수 3안타(1홈런)\n2타점 1득점',
    ),
    AllStarRecord(
      season: '2022',
      player: '정은원',
      team: '한화 이글스',
      record: '2타수 2안타(1홈런)\n3타점 1득점',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '역대 미스터 올스타',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '최근 10년',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
            ),
          ],
        ),
        SizedBox(height: 16),
        _AllStarTable(records: _records),
      ],
    );
  }
}

class _AllStarTable extends StatelessWidget {
  const _AllStarTable({required this.records});

  final List<AllStarRecord> records;

  static const TextStyle _headerStyle = TextStyle(
    color: Color(0xFF9E9E9E),
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _cellStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    height: 1.4,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(
          season: const Text('시즌', style: _headerStyle),
          player: const Text('선수', style: _headerStyle),
          team: const Text('소속팀', style: _headerStyle),
          record: const Text('기록', style: _headerStyle),
        ),
        const Divider(color: Color(0xFF2C2C2E), height: 24),
        for (final record in records) ...[
          _buildRow(
            season: Text(record.season, style: _cellStyle),
            player: Text(record.player, style: _cellStyle),
            team: Text(record.team, style: _cellStyle),
            record: Text(record.record, style: _cellStyle),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  static Widget _buildRow({
    required Widget season,
    required Widget player,
    required Widget team,
    required Widget record,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: season),
        Expanded(flex: 3, child: player),
        Expanded(flex: 4, child: team),
        Expanded(flex: 5, child: record),
      ],
    );
  }
}
