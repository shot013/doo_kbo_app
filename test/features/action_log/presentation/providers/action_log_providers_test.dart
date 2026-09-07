import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/failures.dart';
import 'package:jikgwan/core/utils/result.dart';
import 'package:jikgwan/features/action_log/data/datasources/action_log_local_data_source.dart';
import 'package:jikgwan/features/action_log/data/models/action_log_model.dart';
import 'package:jikgwan/features/action_log/domain/entities/action_log.dart';
import 'package:jikgwan/features/action_log/domain/repositories/action_log_repository.dart';
import 'package:jikgwan/features/action_log/domain/usecases/send_action_logs.dart';
import 'package:jikgwan/features/action_log/presentation/providers/action_log_providers.dart';

class _FakeActionLogRepository implements ActionLogRepository {
  _FakeActionLogRepository({this.shouldFail = false});

  final bool shouldFail;
  final List<List<ActionLog>> sentBatches = [];

  @override
  Future<Result<void>> sendLogs(List<ActionLog> logs) async {
    if (shouldFail) {
      return const Err(ServerFailure());
    }
    sentBatches.add(logs);
    return const Ok(null);
  }
}

class _FakeActionLogLocalDataSource implements ActionLogLocalDataSource {
  final List<ActionLogModel> _stored = [];

  @override
  Future<void> append(ActionLogModel log) async {
    _stored.add(log);
  }

  @override
  Future<List<ActionLogModel>> readAll() async => List.of(_stored);

  @override
  Future<void> clear() async {
    _stored.clear();
  }
}

Route<void> _routeNamed(String? name, {Map<String, String>? arguments}) {
  return MaterialPageRoute<void>(
    settings: RouteSettings(name: name, arguments: arguments),
    builder: (context) => const SizedBox.shrink(),
  );
}

void main() {
  late _FakeActionLogLocalDataSource localDataSource;
  ActionLogService? service;

  setUp(() {
    localDataSource = _FakeActionLogLocalDataSource();
  });

  tearDown(() {
    service?.dispose();
  });

  ActionLogService buildService(_FakeActionLogRepository repository) {
    // 실제 1분 타이머가 테스트 중 발동하지 않도록 긴 주기를 준다.
    return service = ActionLogService(
      SendActionLogs(repository),
      localDataSource,
      flushInterval: const Duration(days: 1),
    );
  }

  group('ActionLogService', () {
    test('flush does nothing when nothing is persisted', () async {
      final repository = _FakeActionLogRepository();
      final service = buildService(repository);

      await service.flush();

      expect(repository.sentBatches, isEmpty);
    });

    test('recordNavigation persists immediately, before any flush', () async {
      final repository = _FakeActionLogRepository();
      final service = buildService(repository);

      service.recordNavigation(route: 'home');
      // append()는 내부에 await이 없어 동기적으로 완료되지만, 실제 앱 종료
      // 상황을 흉내 내기 위해 flush를 호출하지 않고 저장소만 확인한다.
      final persisted = await localDataSource.readAll();

      expect(persisted, hasLength(1));
      expect(persisted.single.route, 'home');
    });

    test(
      'flush sends every persisted log in one batch and clears it',
      () async {
        final repository = _FakeActionLogRepository();
        final service = buildService(repository);

        service.recordNavigation(route: 'home');
        service.recordNavigation(route: 'teams', previousRoute: 'home');

        await service.flush();

        expect(repository.sentBatches, hasLength(1));
        expect(repository.sentBatches.single, hasLength(2));
        expect(repository.sentBatches.single.first.route, 'home');
        expect(repository.sentBatches.single.last.previousRoute, 'home');
        expect(await localDataSource.readAll(), isEmpty);
      },
    );

    test('keeps logs persisted for a retry when sending fails', () async {
      final repository = _FakeActionLogRepository(shouldFail: true);
      final service = buildService(repository);

      service.recordNavigation(route: 'home');
      await service.flush();

      expect(repository.sentBatches, isEmpty);
      expect(await localDataSource.readAll(), hasLength(1));
    });
  });

  group('ActionLogNavigatorObserver', () {
    test('didPush records the pushed route as current', () async {
      final repository = _FakeActionLogRepository();
      final service = buildService(repository);
      final observer = ActionLogNavigatorObserver(service);

      observer.didPush(
        _routeNamed('teams', arguments: {'tab': '1'}),
        _routeNamed('home'),
      );
      await service.flush();

      final log = repository.sentBatches.single.single;
      expect(log.route, 'teams');
      expect(log.previousRoute, 'home');
      expect(log.params, {'tab': '1'});
    });

    test('didPop records the route now showing as current', () async {
      final repository = _FakeActionLogRepository();
      final service = buildService(repository);
      final observer = ActionLogNavigatorObserver(service);

      observer.didPop(_routeNamed('team-detail'), _routeNamed('teams'));
      await service.flush();

      final log = repository.sentBatches.single.single;
      expect(log.route, 'teams');
      expect(log.previousRoute, 'team-detail');
    });

    test('didReplace records the new route as current', () async {
      final repository = _FakeActionLogRepository();
      final service = buildService(repository);
      final observer = ActionLogNavigatorObserver(service);

      observer.didReplace(
        newRoute: _routeNamed('team-detail'),
        oldRoute: _routeNamed('teams'),
      );
      await service.flush();

      final log = repository.sentBatches.single.single;
      expect(log.route, 'team-detail');
      expect(log.previousRoute, 'teams');
    });

    test('ignores navigation with no route name', () async {
      final repository = _FakeActionLogRepository();
      final service = buildService(repository);
      final observer = ActionLogNavigatorObserver(service);

      observer.didPush(_routeNamed(null), null);
      await service.flush();

      expect(repository.sentBatches, isEmpty);
    });
  });
}
