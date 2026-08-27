import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/constants/player_position.dart';
import 'package:jikgwan/features/player/data/models/player_detail_model.dart';

void main() {
  group('PlayerDetailModel.fromJson', () {
    test('parses statLines and vsTeamStats', () {
      final model = PlayerDetailModel.fromJson({
        'id': '54529',
        'name': '레이예스',
        'teamCode': 'LT',
        'teamName': '롯데 자이언츠',
        'position': 'outfielder',
        'backNumber': 29,
        'statLines': [
          {'label': '타율', 'value': '0.359'},
          {'label': '경기', 'value': '109'},
        ],
        'vsTeamStats': [
          {'teamCode': 'OB', 'teamName': '두산 베어스', 'games': 13, 'avg': '0.439'},
        ],
        'vsPitcherStats': [
          {
            'pitcherId': 68830,
            'pitcherName': '김정우',
            'pitcherTeamCode': 'OB',
            'atBats': 1,
            'hits': 1,
            'avg': '1.000',
          },
        ],
      });

      expect(model.position, PlayerPosition.outfielder);
      expect(model.statLines, hasLength(2));
      expect(model.statLines.first.label, '타율');
      expect(model.statLines.first.value, '0.359');
      expect(model.vsTeamStats, hasLength(1));
      expect(model.vsTeamStats.first.teamCode, 'OB');
      expect(model.vsTeamStats.first.games, 13);
      expect(model.vsTeamStats.first.avg, '0.439');
      expect(model.vsPitcherStats, hasLength(1));
      expect(model.vsPitcherStats.first.pitcherId, 68830);
      expect(model.vsPitcherStats.first.pitcherName, '김정우');
      expect(model.vsPitcherStats.first.pitcherTeamCode, 'OB');
      expect(model.vsPitcherStats.first.atBats, 1);
      expect(model.vsPitcherStats.first.hits, 1);
      expect(model.vsPitcherStats.first.avg, '1.000');
      expect(model.vsBatterStats, isEmpty);
    });

    test('parses vsBatterStats for pitchers', () {
      final model = PlayerDetailModel.fromJson({
        'id': '99001',
        'name': '김광현',
        'teamCode': 'SK',
        'teamName': 'SSG 랜더스',
        'position': 'pitcher',
        'backNumber': 29,
        'vsBatterStats': [
          {
            'batterId': 54944,
            'batterName': '데이비슨',
            'batterTeamCode': 'NC',
            'atBats': 1,
            'strikeouts': 1,
            'strikeoutRate': '1.000',
          },
        ],
      });

      expect(model.vsBatterStats, hasLength(1));
      expect(model.vsBatterStats.first.batterId, 54944);
      expect(model.vsBatterStats.first.batterName, '데이비슨');
      expect(model.vsBatterStats.first.batterTeamCode, 'NC');
      expect(model.vsBatterStats.first.atBats, 1);
      expect(model.vsBatterStats.first.strikeouts, 1);
      expect(model.vsBatterStats.first.strikeoutRate, '1.000');
      expect(model.vsPitcherStats, isEmpty);
    });

    test('defaults statLines, vsTeamStats, vsPitcherStats, vsBatterStats to '
        'empty lists when missing', () {
      final model = PlayerDetailModel.fromJson({
        'id': '54529',
        'name': '레이예스',
        'teamCode': 'LT',
        'teamName': '롯데 자이언츠',
        'position': 'outfielder',
        'backNumber': 29,
      });

      expect(model.statLines, isEmpty);
      expect(model.vsTeamStats, isEmpty);
      expect(model.vsPitcherStats, isEmpty);
      expect(model.vsBatterStats, isEmpty);
    });
  });
}
