import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/standing/data/datasources/standing_remote_data_source.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('StandingRemoteDataSourceImpl.getStandings', () {
    test(
      'parses a successful /standings response into StandingModel list',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = FakeHttpClientAdapter.success({
            'data': [
              {
                'seasonYear': 2026,
                'teamCode': 'KT',
                'teamName': 'kt wiz',
                'rank': 1,
                'gamesPlayed': 107,
                'wins': 63,
                'losses': 41,
                'draws': 3,
                'winRate': '0.606',
                'gamesBehind': '0.0',
                'streak': '1승',
                'last10': '4승1무5패',
                'homeRecord': '31-1-20',
                'awayRecord': '32-2-21',
              },
            ],
          });
        final dataSource = StandingRemoteDataSourceImpl(dio);

        final standings = await dataSource.getStandings();

        expect(standings, hasLength(1));
        expect(standings.first.teamCode, 'KT');
        expect(standings.first.rank, 1);
      },
    );

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/standings'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = StandingRemoteDataSourceImpl(dio);

      expect(dataSource.getStandings(), throwsA(isA<ServerException>()));
    });
  });
}
