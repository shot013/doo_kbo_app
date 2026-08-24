import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/record/domain/entities/batter_record.dart';
import 'package:jikgwan/features/record/presentation/widgets/batter_record_table.dart';

void main() {
  testWidgets('renders a row per record', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BatterRecordTable(
            records: [
              BatterRecord(
                rank: 1,
                playerId: 54529,
                playerName: '레이예스',
                teamCode: 'LT',
                teamName: '롯데 자이언츠',
                avg: '0.359',
                games: 109,
                homeRuns: 13,
                rbi: 79,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('레이예스'), findsOneWidget);
    expect(find.text('0.359'), findsOneWidget);
  });

  testWidgets('renders only the header when records is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BatterRecordTable(records: [])),
      ),
    );

    expect(find.text('순위'), findsOneWidget);
    expect(find.byType(GestureDetector), findsNothing);
  });
}
