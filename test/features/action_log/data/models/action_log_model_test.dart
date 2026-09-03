import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/action_log/data/models/action_log_model.dart';

void main() {
  group('ActionLogModel.toJson', () {
    test('includes optional fields when present', () {
      final model = ActionLogModel(
        route: 'team-detail',
        occurredAt: DateTime.utc(2026, 9, 3, 12),
        previousRoute: 'teams',
        params: const {'code': 'KT'},
        platform: 'android',
        osVersion: '14',
      );

      expect(model.toJson(), {
        'route': 'team-detail',
        'occurredAt': '2026-09-03T12:00:00.000Z',
        'previousRoute': 'teams',
        'params': {'code': 'KT'},
        'platform': 'android',
        'osVersion': '14',
      });
    });

    test('omits optional fields when absent', () {
      final model = ActionLogModel(
        route: 'home',
        occurredAt: DateTime.utc(2026, 9, 3, 12),
      );

      expect(model.toJson(), {
        'route': 'home',
        'occurredAt': '2026-09-03T12:00:00.000Z',
      });
    });

    test('fromEntity copies every field from the entity', () {
      final model = ActionLogModel(
        route: 'team-detail',
        occurredAt: DateTime.utc(2026, 9, 3, 12),
        previousRoute: 'teams',
        params: const {'code': 'KT'},
        platform: 'android',
        osVersion: '14',
      );

      final copy = ActionLogModel.fromEntity(model);

      expect(copy.toJson(), model.toJson());
    });
  });

  group('ActionLogModel.fromJson', () {
    test('round-trips every field through toJson', () {
      final original = ActionLogModel(
        route: 'team-detail',
        occurredAt: DateTime.utc(2026, 9, 3, 12),
        previousRoute: 'teams',
        params: const {'code': 'KT'},
        platform: 'android',
        osVersion: '14',
      );

      final parsed = ActionLogModel.fromJson(original.toJson());

      expect(parsed.toJson(), original.toJson());
    });

    test('optional fields are null when the JSON omits them', () {
      final parsed = ActionLogModel.fromJson({
        'route': 'home',
        'occurredAt': '2026-09-03T12:00:00.000Z',
      });

      expect(parsed.previousRoute, isNull);
      expect(parsed.params, isNull);
      expect(parsed.platform, isNull);
      expect(parsed.osVersion, isNull);
    });
  });
}
