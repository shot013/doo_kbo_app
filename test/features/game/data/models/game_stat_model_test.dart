import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/game/data/models/game_stat_model.dart';
import 'package:jikgwan/features/game/domain/entities/player_stat_type.dart';

void main() {
  group('GameStatModel.fromJson', () {
    test('parses a batting line', () {
      final model = GameStatModel.fromJson({
        'id': 1,
        'gameId': '20260820KTLG0',
        'teamCode': 'KT',
        'playerName': '강백호',
        'playerNo': '50',
        'statType': 'BATTING',
        'atBats': 4,
        'hits': 2,
        'doubles': 1,
        'triples': 0,
        'homeRuns': 0,
        'rbi': 1,
        'runs': 1,
        'walks': 0,
        'strikeouts': 1,
        'stolenBases': 0,
        'battingAverage': '0.500',
        'inningsPitched': null,
        'hitsAllowed': null,
        'earnedRuns': null,
        'strikeoutsPitched': null,
        'walksAllowed': null,
        'homeRunsAllowed': null,
        'win': false,
        'loss': false,
        'save': false,
        'hold': false,
        'era': null,
      });

      expect(model.id, 1);
      expect(model.statType, PlayerStatType.batting);
      expect(model.atBats, 4);
      expect(model.hits, 2);
      expect(model.battingAverage, '0.500');
      expect(model.win, isFalse);
      expect(model.inningsPitched, isNull);
    });

    test('parses a pitching line', () {
      final model = GameStatModel.fromJson({
        'id': 2,
        'gameId': '20260820KTLG0',
        'teamCode': 'LG',
        'playerName': '케네디',
        'playerNo': '19',
        'statType': 'PITCHING',
        'atBats': null,
        'hits': null,
        'doubles': null,
        'triples': null,
        'homeRuns': null,
        'rbi': null,
        'runs': null,
        'walks': null,
        'strikeouts': null,
        'stolenBases': null,
        'battingAverage': null,
        'inningsPitched': '6.0',
        'hitsAllowed': 5,
        'earnedRuns': 2,
        'strikeoutsPitched': 6,
        'walksAllowed': 1,
        'homeRunsAllowed': 0,
        'win': true,
        'loss': false,
        'save': false,
        'hold': false,
        'era': '2.15',
      });

      expect(model.statType, PlayerStatType.pitching);
      expect(model.inningsPitched, '6.0');
      expect(model.win, isTrue);
      expect(model.era, '2.15');
      expect(model.atBats, isNull);
    });

    test('throws for an unknown stat type', () {
      expect(
        () => GameStatModel.fromJson({
          'id': 1,
          'gameId': '20260820KTLG0',
          'teamCode': 'KT',
          'playerName': '강백호',
          'playerNo': null,
          'statType': 'UNKNOWN',
          'atBats': null,
          'hits': null,
          'doubles': null,
          'triples': null,
          'homeRuns': null,
          'rbi': null,
          'runs': null,
          'walks': null,
          'strikeouts': null,
          'stolenBases': null,
          'battingAverage': null,
          'inningsPitched': null,
          'hitsAllowed': null,
          'earnedRuns': null,
          'strikeoutsPitched': null,
          'walksAllowed': null,
          'homeRunsAllowed': null,
          'win': false,
          'loss': false,
          'save': false,
          'hold': false,
          'era': null,
        }),
        throwsArgumentError,
      );
    });
  });
}
