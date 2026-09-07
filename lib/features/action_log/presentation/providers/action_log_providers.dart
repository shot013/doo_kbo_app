import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/shared_preferences_provider.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/action_log_local_data_source.dart';
import '../../data/datasources/action_log_remote_data_source.dart';
import '../../data/models/action_log_model.dart';
import '../../data/repositories/action_log_repository_impl.dart';
import '../../domain/repositories/action_log_repository.dart';
import '../../domain/usecases/send_action_logs.dart';

const _flushInterval = Duration(minutes: 1);

final actionLogRemoteDataSourceProvider = Provider<ActionLogRemoteDataSource>(
  (ref) => ActionLogRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final actionLogLocalDataSourceProvider = Provider<ActionLogLocalDataSource>(
  (ref) => ActionLogLocalDataSourceImpl(ref.watch(sharedPreferencesProvider)),
);

final actionLogRepositoryProvider = Provider<ActionLogRepository>((ref) {
  return ActionLogRepositoryImpl(
    ref.watch(actionLogRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final sendActionLogsProvider = Provider<SendActionLogs>((ref) {
  return SendActionLogs(ref.watch(actionLogRepositoryProvider));
});

/// 라우트 이동 로그를 기록되는 즉시 기기에 영속화해뒀다가 [_flushInterval]마다
/// 서버로 일괄 전송한다. 메모리에만 버퍼링하면 flush 주기가 되기 전에 앱이
/// 종료될 때 로그가 통째로 사라지므로, [ActionLogLocalDataSource]에 바로 쓰고
/// 전송에 성공했을 때만 지운다 — 전송 실패 시에도 다음 주기에 자동으로
/// 재시도되는 효과가 있다.
class ActionLogService {
  ActionLogService(
    this._sendActionLogs,
    this._localDataSource, {
    Duration flushInterval = _flushInterval,
  }) {
    _timer = Timer.periodic(flushInterval, (_) => unawaited(flush()));
  }

  final SendActionLogs _sendActionLogs;
  final ActionLogLocalDataSource _localDataSource;
  late final Timer _timer;

  void recordNavigation({
    required String route,
    String? previousRoute,
    Map<String, String>? params,
  }) {
    unawaited(
      _localDataSource.append(
        ActionLogModel(
          route: route,
          previousRoute: previousRoute,
          params: params,
          platform: Platform.operatingSystem,
          osVersion: Platform.operatingSystemVersion,
          occurredAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> flush() async {
    final logs = await _localDataSource.readAll();
    if (logs.isEmpty) {
      return;
    }
    final result = await _sendActionLogs.call(SendActionLogsParams(logs));
    switch (result) {
      case Ok<void>():
        await _localDataSource.clear();
      case Err<void>():
        break;
    }
  }

  void dispose() {
    _timer.cancel();
  }
}

/// 화면 이동마다 [ActionLogService]에 현재/이전 라우트를 기록하는 observer.
class ActionLogNavigatorObserver extends NavigatorObserver {
  ActionLogNavigatorObserver(this._service);

  final ActionLogService _service;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(current: route, from: previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _record(current: previousRoute, from: route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _record(current: newRoute, from: oldRoute);
  }

  void _record({
    required Route<dynamic>? current,
    required Route<dynamic>? from,
  }) {
    final route = current?.settings.name;
    if (route == null) {
      return;
    }
    _service.recordNavigation(
      route: route,
      previousRoute: from?.settings.name,
      params: current?.settings.arguments as Map<String, String>?,
    );
  }
}

final actionLogServiceProvider = Provider<ActionLogService>((ref) {
  final service = ActionLogService(
    ref.watch(sendActionLogsProvider),
    ref.watch(actionLogLocalDataSourceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final actionLogObserverProvider = Provider<NavigatorObserver>((ref) {
  return ActionLogNavigatorObserver(ref.watch(actionLogServiceProvider));
});
