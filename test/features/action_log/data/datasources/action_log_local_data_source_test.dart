import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/features/action_log/data/datasources/action_log_local_data_source.dart';
import 'package:jikgwan/features/action_log/data/models/action_log_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ActionLogLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    dataSource = ActionLogLocalDataSourceImpl(preferences);
  });

  group('ActionLogLocalDataSourceImpl', () {
    test('readAll returns an empty list when nothing was appended', () async {
      expect(await dataSource.readAll(), isEmpty);
    });

    test('append persists logs across separate reads', () async {
      await dataSource.append(
        ActionLogModel(route: 'home', occurredAt: DateTime.utc(2026)),
      );
      await dataSource.append(
        ActionLogModel(
          route: 'teams',
          previousRoute: 'home',
          occurredAt: DateTime.utc(2026, 1, 1, 0, 1),
        ),
      );

      final logs = await dataSource.readAll();

      expect(logs, hasLength(2));
      expect(logs.first.route, 'home');
      expect(logs.last.route, 'teams');
      expect(logs.last.previousRoute, 'home');
    });

    test(
      'a second data source instance sees what the first persisted',
      () async {
        await dataSource.append(
          ActionLogModel(
            route: 'team-detail',
            params: const {'code': 'KT'},
            occurredAt: DateTime.utc(2026),
          ),
        );

        final preferences = await SharedPreferences.getInstance();
        final reopened = ActionLogLocalDataSourceImpl(preferences);
        final logs = await reopened.readAll();

        expect(logs, hasLength(1));
        expect(logs.single.params, {'code': 'KT'});
      },
    );

    test('clear removes everything persisted', () async {
      await dataSource.append(
        ActionLogModel(route: 'home', occurredAt: DateTime.utc(2026)),
      );

      await dataSource.clear();

      expect(await dataSource.readAll(), isEmpty);
    });
  });
}
