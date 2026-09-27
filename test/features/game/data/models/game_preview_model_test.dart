import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/game/data/models/game_preview_model.dart';

void main() {
  group('GamePreviewModel.fromJson', () {
    test('parses home/away starter pitcher names', () {
      final model = GamePreviewModel.fromJson({
        'gameId': '20260927KTOB0',
        'homePitcherName': '최승용',
        'homePitcherStyle': '좌투좌타',
        'awayPitcherName': '배제성',
        'awayPitcherStyle': '우투좌타',
        'scrapedAt': '2026-09-27T00:00:01.174Z',
        'createdAt': '2026-09-27T00:00:01.174Z',
        'updatedAt': '2026-09-27T00:00:01.174Z',
      });

      expect(model.homePitcher.name, '최승용');
      expect(model.homePitcher.style, '좌투좌타');
      expect(model.awayPitcher.name, '배제성');
      expect(model.awayPitcher.style, '우투좌타');
    });

    test('pitcher name is null when the API omits it', () {
      final model = GamePreviewModel.fromJson({
        'gameId': '20260927KTOB0',
        'scrapedAt': '2026-09-27T00:00:01.174Z',
        'createdAt': '2026-09-27T00:00:01.174Z',
        'updatedAt': '2026-09-27T00:00:01.174Z',
      });

      expect(model.homePitcher.name, isNull);
      expect(model.awayPitcher.name, isNull);
    });
  });
}
