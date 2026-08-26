import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/standing/data/models/standing_model.dart';

void main() {
  group('StandingModel.fromJson', () {
    test('parses every field', () {
      final model = StandingModel.fromJson({
        'seasonYear': 2026,
        'teamCode': 'KT',
        'teamName': 'kt wiz',
        'rank': 1,
        'gamesPlayed': 107,
        'wins': 63,
        'losses': 41,
        'draws': 3,
        'winRate': '0.606',
        'gamesBehind': '0.0',
        'streak': '1승',
        'last10': '4승1무5패',
        'homeRecord': '31-1-20',
        'awayRecord': '32-2-21',
      });

      expect(model.teamCode, 'KT');
      expect(model.teamVisibleName, 'KT');
      expect(model.rank, 1);
      expect(model.gamesPlayed, 107);
      expect(model.winRate, '0.606');
      expect(model.streak, '1승');
      expect(model.last10, '4승1무5패');
      expect(model.homeRecord, '31-1-20');
      expect(model.awayRecord, '32-2-21');
    });

    test('nullable fields fall back to null when missing', () {
      final model = StandingModel.fromJson({
        'seasonYear': 2026,
        'teamCode': 'KT',
        'teamName': 'kt wiz',
        'rank': 1,
        'gamesPlayed': 107,
        'wins': 63,
        'losses': 41,
        'draws': 3,
        'winRate': '0.606',
        'gamesBehind': null,
        'streak': null,
        'last10': null,
        'homeRecord': null,
        'awayRecord': null,
      });

      expect(model.gamesBehind, isNull);
      expect(model.streak, isNull);
      expect(model.last10, isNull);
      expect(model.homeRecord, isNull);
      expect(model.awayRecord, isNull);
    });
  });
}
