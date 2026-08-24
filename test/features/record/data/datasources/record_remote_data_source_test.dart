import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/record/data/datasources/record_remote_data_source.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('RecordRemoteDataSourceImpl.getBatterRecords', () {
    test('parses a successful /records/batters response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success({
          'data': [
            {
              'rank': 1,
              'playerId': 54529,
              'playerName': '레이예스',
              'teamCode': 'LT',
              'teamName': '롯데 자이언츠',
              'avg': '0.359',
              'games': 109,
              'homeRuns': 13,
              'rbi': 79,
            },
          ],
        });
      final dataSource = RecordRemoteDataSourceImpl(dio);

      final records = await dataSource.getBatterRecords();

      expect(records, hasLength(1));
      expect(records.first.playerName, '레이예스');
    });

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/records/batters'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = RecordRemoteDataSourceImpl(dio);

      expect(dataSource.getBatterRecords(), throwsA(isA<ServerException>()));
    });
  });

  group('RecordRemoteDataSourceImpl.getPitcherRecords', () {
    test('parses a successful /records/pitchers response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success({
          'data': [
            {
              'rank': 1,
              'playerId': 66666,
              'playerName': '고영표',
              'teamCode': 'KT',
              'teamName': 'kt wiz',
              'era': '2.14',
              'games': 26,
              'wins': 16,
              'losses': 4,
              'saves': 0,
            },
          ],
        });
      final dataSource = RecordRemoteDataSourceImpl(dio);

      final records = await dataSource.getPitcherRecords();

      expect(records, hasLength(1));
      expect(records.first.playerName, '고영표');
    });
  });
}
