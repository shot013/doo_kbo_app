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
            'pitcherName': '김광현',
            'teamCode': 'SK',
            'teamName': 'SSG 랜더스',
            'games': 5,
            'avg': '0.321',
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
      expect(model.vsPitcherStats.first.pitcherName, '김광현');
      expect(model.vsPitcherStats.first.teamCode, 'SK');
      expect(model.vsPitcherStats.first.games, 5);
      expect(model.vsPitcherStats.first.avg, '0.321');
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
            'batterName': '레이예스',
            'teamCode': 'LT',
            'teamName': '롯데 자이언츠',
            'games': 8,
            'avg': '0.412',
          },
        ],
      });

      expect(model.vsBatterStats, hasLength(1));
      expect(model.vsBatterStats.first.batterName, '레이예스');
      expect(model.vsBatterStats.first.teamCode, 'LT');
      expect(model.vsBatterStats.first.games, 8);
      expect(model.vsBatterStats.first.avg, '0.412');
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
