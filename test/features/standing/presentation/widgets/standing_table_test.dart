import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/standing/domain/entities/standing.dart';
import 'package:jikgwan/features/standing/presentation/widgets/standing_table.dart';

void main() {
  testWidgets(
    'renders a row per team, truncating the team name to its first word',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandingTable(
              standings: [
                Standing(
                  seasonYear: 2026,
                  teamCode: 'LG',
                  teamName: 'LG 트윈스',
                  rank: 1,
                  gamesPlayed: 110,
                  wins: 65,
                  losses: 44,
                  draws: 1,
                  winRate: '0.596',
                  gamesBehind: '0.0',
                  streak: '1승',
                  last10: '5승0무5패',
                  homeRecord: '32-1-21',
                  awayRecord: '33-0-23',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('LG'), findsOneWidget);
      expect(find.text('LG 트윈스'), findsNothing);
      expect(find.text('0.596'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget);
    },
  );
}
