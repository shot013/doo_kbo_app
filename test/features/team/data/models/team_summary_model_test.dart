import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/team/data/models/team_summary_model.dart';

void main() {
  group('TeamSummaryModel.fromJson', () {
    test('parses every field, including batting average, ERA, and runs', () {
      final json = {
        'teamCode': 'KT',
        'teamName': 'kt wiz',
        'rank': 1,
        'wins': 64,
        'losses': 41,
        'draws': 3,
        'winRate': '0.610',
        'gamesBehind': '0.0',
        'battingAverage': '0.279',
        'era': '5.65',
        'runsScored': 598,
        'runsAllowed': 506,
        'recentForm': ['L', 'L', 'W', 'D', 'W'],
      };

      final model = TeamSummaryModel.fromJson(json);

      expect(model.teamCode, 'KT');
      expect(model.teamName, 'kt wiz');
      expect(model.rank, 1);
      expect(model.wins, 64);
      expect(model.losses, 41);
      expect(model.draws, 3);
      expect(model.winRate, '0.610');
      expect(model.gamesBehind, '0.0');
      expect(model.battingAverage, '0.279');
      expect(model.era, '5.65');
      expect(model.runsScored, 598);
      expect(model.runsAllowed, 506);
      expect(model.recentForm, ['L', 'L', 'W', 'D', 'W']);
    });

    test('defaults recentForm to an empty list when missing', () {
      final json = {
        'teamCode': 'KT',
        'teamName': 'kt wiz',
        'rank': 1,
        'wins': 64,
        'losses': 41,
        'draws': 3,
        'winRate': '0.610',
        'gamesBehind': '0.0',
        'battingAverage': '0.279',
        'era': '5.65',
        'runsScored': 598,
        'runsAllowed': 506,
      };

      final model = TeamSummaryModel.fromJson(json);

      expect(model.recentForm, isEmpty);
    });
  });
}
