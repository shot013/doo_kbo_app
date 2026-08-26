import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/game/data/models/game_result_model.dart';
import 'package:jikgwan/features/game/domain/entities/pitcher_decision_type.dart';

void main() {
  group('GameResultModel.fromJson', () {
    test('parses bestPerformer and pitchers', () {
      final model = GameResultModel.fromJson({
        'gameId': '20260820KTLG0',
        'gameDate': '2026-08-20',
        'stadium': '잠실',
        'homeTeamCode': 'LG',
        'homeTeamName': 'LG 트윈스',
        'awayTeamCode': 'KT',
        'awayTeamName': 'kt wiz',
        'homeScore': 4,
        'awayScore': 16,
        'bestPerformer': {
          'playerName': '힐리어드',
          'teamCode': 'KT',
          'atBats': 3,
          'hits': 2,
          'rbi': 3,
          'runs': 2,
          'line': '3타수 2안타 3타점',
        },
        'pitchers': [
          {
            'decision': 'WIN',
            'playerName': '고영표',
            'teamCode': 'KT',
            'inningsPitched': '6.0',
            'earnedRuns': 3,
            'strikeoutsPitched': 6,
            'era': '3.74',
          },
          {
            'decision': 'LOSS',
            'playerName': '케네디',
            'teamCode': 'LG',
            'inningsPitched': null,
            'earnedRuns': 3,
            'strikeoutsPitched': 1,
            'era': '13.50',
          },
        ],
      });

      expect(model.homeScore, 4);
      expect(model.awayScore, 16);
      expect(model.homeTeamVisibleName, 'LG');
      expect(model.awayTeamVisibleName, 'kt');
      expect(model.bestPerformer, isNotNull);
      expect(model.bestPerformer!.playerName, '힐리어드');
      expect(model.bestPerformer!.line, '3타수 2안타 3타점');
      expect(model.pitchers, hasLength(2));
      expect(model.pitchers.first.decision, PitcherDecisionType.win);
      expect(model.pitchers.last.decision, PitcherDecisionType.loss);
      expect(model.pitchers.last.inningsPitched, isNull);
    });

    test('bestPerformer is null when the JSON value is null', () {
      final model = GameResultModel.fromJson({
        'gameId': '20260820KTLG0',
        'gameDate': '2026-08-20',
        'stadium': '잠실',
        'homeTeamCode': 'LG',
        'homeTeamName': 'LG 트윈스',
        'awayTeamCode': 'KT',
        'awayTeamName': 'kt wiz',
        'homeScore': 0,
        'awayScore': 0,
        'bestPerformer': null,
        'pitchers': <Map<String, dynamic>>[],
      });

      expect(model.bestPerformer, isNull);
      expect(model.pitchers, isEmpty);
    });

    test('maps every known decision string', () {
      final expected = {
        'WIN': PitcherDecisionType.win,
        'LOSS': PitcherDecisionType.loss,
        'SAVE': PitcherDecisionType.save,
        'HOLD': PitcherDecisionType.hold,
      };

      for (final entry in expected.entries) {
        final model = GameResultModel.fromJson({
          'gameId': '20260820KTLG0',
          'gameDate': '2026-08-20',
          'stadium': '잠실',
          'homeTeamCode': 'LG',
          'homeTeamName': 'LG 트윈스',
          'awayTeamCode': 'KT',
          'awayTeamName': 'kt wiz',
          'homeScore': 0,
          'awayScore': 0,
          'bestPerformer': null,
          'pitchers': [
            {
              'decision': entry.key,
              'playerName': '선수',
              'teamCode': 'KT',
              'inningsPitched': null,
              'earnedRuns': null,
              'strikeoutsPitched': null,
              'era': null,
            },
          ],
        });
        expect(model.pitchers.single.decision, entry.value, reason: entry.key);
      }
    });
  });
}
