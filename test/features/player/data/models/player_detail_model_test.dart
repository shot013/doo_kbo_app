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
      });

      expect(model.position, PlayerPosition.outfielder);
      expect(model.statLines, hasLength(2));
      expect(model.statLines.first.label, '타율');
      expect(model.statLines.first.value, '0.359');
      expect(model.vsTeamStats, hasLength(1));
      expect(model.vsTeamStats.first.teamCode, 'OB');
      expect(model.vsTeamStats.first.games, 13);
      expect(model.vsTeamStats.first.avg, '0.439');
    });

    test('defaults statLines and vsTeamStats to empty lists when missing', () {
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
    });
  });
}
