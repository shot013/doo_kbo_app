import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/team/data/models/team_detail_model.dart';

import '../../../../support/player_fixtures.dart';
import '../../../../support/team_fixtures.dart';

void main() {
  group('TeamDetailModel.fromJson', () {
    test('parses summary and roster', () {
      final model = TeamDetailModel.fromJson({
        'summary': teamSummaryJson(),
        'roster': [playerSummaryJson()],
      });

      expect(model.summary.teamCode, 'KT');
      expect(model.summary.teamName, 'kt wiz');
      expect(model.roster, hasLength(1));
      expect(model.roster.first.name, '레이예스');
    });

    test('defaults roster to an empty list when missing', () {
      final model = TeamDetailModel.fromJson({'summary': teamSummaryJson()});

      expect(model.roster, isEmpty);
    });
  });
}
