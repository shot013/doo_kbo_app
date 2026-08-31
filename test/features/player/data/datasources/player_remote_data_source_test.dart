import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/player/data/datasources/player_remote_data_source.dart';

import '../../../../support/fake_http_client_adapter.dart';
import '../../../../support/player_fixtures.dart';

void main() {
  group('PlayerRemoteDataSourceImpl.getPlayers', () {
    test(
      'parses a successful /players response into PlayerSummaryModel list',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = FakeHttpClientAdapter.success({
            'data': [playerSummaryJson()],
          });
        final dataSource = PlayerRemoteDataSourceImpl(dio);

        final players = await dataSource.getPlayers();

        expect(players, hasLength(1));
        expect(players.first.name, '레이예스');
      },
    );

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/players'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = PlayerRemoteDataSourceImpl(dio);

      expect(dataSource.getPlayers(), throwsA(isA<ServerException>()));
    });
  });

  group('PlayerRemoteDataSourceImpl.getPlayerDetail', () {
    test('parses the response body directly (no "data" envelope)', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success({
          ...playerSummaryJson(),
          'statLines': <Map<String, dynamic>>[],
          'vsTeamStats': <Map<String, dynamic>>[],
        });
      final dataSource = PlayerRemoteDataSourceImpl(dio);

      final detail = await dataSource.getPlayerDetail('54529');

      expect(detail.id, '54529');
      expect(detail.name, '레이예스');
    });

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/players/54529'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = PlayerRemoteDataSourceImpl(dio);

      expect(
        dataSource.getPlayerDetail('54529'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
