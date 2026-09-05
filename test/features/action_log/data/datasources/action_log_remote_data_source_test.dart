import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/action_log/data/datasources/action_log_remote_data_source.dart';
import 'package:jikgwan/features/action_log/data/models/action_log_model.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('ActionLogRemoteDataSourceImpl.sendLogs', () {
    test('posts the batched logs without throwing on success', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success({'status': 'ok'});
      final dataSource = ActionLogRemoteDataSourceImpl(dio);

      await expectLater(
        dataSource.sendLogs([
          ActionLogModel(route: 'home', occurredAt: DateTime.utc(2026)),
        ]),
        completes,
      );
    });

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/action-logs'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = ActionLogRemoteDataSourceImpl(dio);

      expect(
        dataSource.sendLogs([
          ActionLogModel(route: 'home', occurredAt: DateTime.utc(2026)),
        ]),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
