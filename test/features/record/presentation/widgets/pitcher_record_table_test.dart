import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/record/domain/entities/pitcher_record.dart';
import 'package:jikgwan/features/record/presentation/widgets/pitcher_record_table.dart';

void main() {
  testWidgets('renders a row per record', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PitcherRecordTable(
            records: [
              PitcherRecord(
                rank: 1,
                playerId: 66666,
                playerName: '고영표',
                teamCode: 'KT',
                teamName: 'kt wiz',
                era: '2.14',
                games: 26,
                wins: 16,
                losses: 4,
                saves: 0,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('고영표'), findsOneWidget);
    expect(find.text('2.14'), findsOneWidget);
  });

  testWidgets('renders only the header when records is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PitcherRecordTable(records: [])),
      ),
    );

    expect(find.text('순위'), findsOneWidget);
    expect(find.byType(GestureDetector), findsNothing);
  });
}
