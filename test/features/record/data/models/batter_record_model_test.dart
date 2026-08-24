import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/record/data/models/batter_record_model.dart';

void main() {
  group('BatterRecordModel.fromJson', () {
    test('parses every field', () {
      final model = BatterRecordModel.fromJson({
        'rank': 1,
        'playerId': 54529,
        'playerName': '레이예스',
        'teamCode': 'LT',
        'teamName': '롯데 자이언츠',
        'avg': '0.359',
        'games': 109,
        'homeRuns': 13,
        'rbi': 79,
      });

      expect(model.rank, 1);
      expect(model.playerId, 54529);
      expect(model.avg, '0.359');
      expect(model.homeRuns, 13);
      expect(model.rbi, 79);
    });

    test('playerId is null when the JSON value is null', () {
      final model = BatterRecordModel.fromJson({
        'rank': 1,
        'playerId': null,
        'playerName': '레이예스',
        'teamCode': 'LT',
        'teamName': '롯데 자이언츠',
        'avg': '0.359',
        'games': 109,
        'homeRuns': 13,
        'rbi': 79,
      });

      expect(model.playerId, isNull);
    });
  });
}
