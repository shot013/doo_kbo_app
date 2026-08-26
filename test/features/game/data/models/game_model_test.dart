import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/game/data/models/game_model.dart';
import 'package:jikgwan/features/game/domain/entities/game_status.dart';

void main() {
  group('GameModel.fromJson', () {
    Map<String, dynamic> baseJson({String status = 'SCHEDULED'}) => {
      'id': '20260820KTLG0',
      'seasonYear': 2026,
      'gameDate': '2026-08-20',
      'scheduledAt': '2026-08-20T10:00:00.000Z',
      'stadium': '잠실',
      'homeTeamCode': 'LG',
      'homeTeamName': 'LG 트윈스',
      'awayTeamCode': 'KT',
      'awayTeamName': 'kt wiz',
      'homeScore': null,
      'awayScore': null,
      'homeStarterPitcher': '박시원',
      'awayStarterPitcher': '고영표',
      'currentInning': null,
      'status': status,
    };

    test('parses every field including starter pitchers', () {
      final model = GameModel.fromJson(baseJson());

      expect(model.id, '20260820KTLG0');
      expect(model.seasonYear, 2026);
      expect(model.gameDate, '2026-08-20');
      expect(model.scheduledAt, DateTime.parse('2026-08-20T10:00:00.000Z'));
      expect(model.stadium, '잠실');
      expect(model.homeTeamCode, 'LG');
      expect(model.homeTeamVisibleName, 'LG');
      expect(model.awayTeamCode, 'KT');
      expect(model.awayTeamVisibleName, 'KT');
      expect(model.homeScore, isNull);
      expect(model.awayScore, isNull);
      expect(model.homeStarterPitcher, '박시원');
      expect(model.awayStarterPitcher, '고영표');
      expect(model.status, GameStatus.scheduled);
    });

    test('maps every known status string', () {
      final expected = {
        'SCHEDULED': GameStatus.scheduled,
        'IN_PROGRESS': GameStatus.inProgress,
        'FINISHED': GameStatus.finished,
        'CANCELLED': GameStatus.cancelled,
        'POSTPONED': GameStatus.postponed,
      };

      for (final entry in expected.entries) {
        final model = GameModel.fromJson(baseJson(status: entry.key));
        expect(model.status, entry.value, reason: entry.key);
      }
    });

    test('throws for an unknown status string', () {
      expect(
        () => GameModel.fromJson(baseJson(status: 'UNKNOWN')),
        throwsArgumentError,
      );
    });
  });
}
