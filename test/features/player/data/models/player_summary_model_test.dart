import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/constants/player_position.dart';
import 'package:jikgwan/features/player/data/models/player_summary_model.dart';

void main() {
  group('PlayerSummaryModel.fromJson', () {
    test('parses every field, mapping position by lowercase enum name', () {
      final model = PlayerSummaryModel.fromJson({
        'id': '54529',
        'name': '레이예스',
        'teamCode': 'LT',
        'teamName': '롯데 자이언츠',
        'position': 'outfielder',
        'backNumber': 29,
        'primaryStat': '타율 0.359',
      });

      expect(model.id, '54529');
      expect(model.name, '레이예스');
      expect(model.teamCode, 'LT');
      expect(model.position, PlayerPosition.outfielder);
      expect(model.backNumber, 29);
      expect(model.primaryStat, '타율 0.359');
    });

    test('maps every known position string', () {
      final expected = {
        'pitcher': PlayerPosition.pitcher,
        'catcher': PlayerPosition.catcher,
        'infielder': PlayerPosition.infielder,
        'outfielder': PlayerPosition.outfielder,
      };

      for (final entry in expected.entries) {
        final model = PlayerSummaryModel.fromJson({
          'id': '1',
          'name': '선수',
          'teamCode': 'KT',
          'teamName': 'kt wiz',
          'position': entry.key,
          'backNumber': 1,
          'primaryStat': '',
        });
        expect(model.position, entry.value, reason: entry.key);
      }
    });
  });
}
