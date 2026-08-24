import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/record/data/models/pitcher_record_model.dart';

void main() {
  group('PitcherRecordModel.fromJson', () {
    test('parses every field', () {
      final model = PitcherRecordModel.fromJson({
        'rank': 1,
        'playerId': 66666,
        'playerName': '고영표',
        'teamCode': 'KT',
        'teamName': 'kt wiz',
        'era': '2.14',
        'games': 26,
        'wins': 16,
        'losses': 4,
        'saves': 0,
      });

      expect(model.rank, 1);
      expect(model.playerId, 66666);
      expect(model.era, '2.14');
      expect(model.wins, 16);
      expect(model.losses, 4);
      expect(model.saves, 0);
    });

    test('era defaults to "0.00" when the JSON value is null', () {
      final model = PitcherRecordModel.fromJson({
        'rank': 1,
        'playerId': null,
        'playerName': '고영표',
        'teamCode': 'KT',
        'teamName': 'kt wiz',
        'era': null,
        'games': 26,
        'wins': 16,
        'losses': 4,
        'saves': 0,
      });

      expect(model.era, '0.00');
      expect(model.playerId, isNull);
    });
  });
}
