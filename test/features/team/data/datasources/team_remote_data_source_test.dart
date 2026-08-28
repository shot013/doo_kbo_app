import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/team/data/datasources/team_remote_data_source.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('TeamRemoteDataSourceImpl.getTeams', () {
    test(
      'parses a successful /teams response into TeamSummaryModel list',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = FakeHttpClientAdapter.success({
            'data': [
              {
                'teamCode': 'KT',
                'teamName': 'kt wiz',
                'rank': 1,
                'wins': 64,
                'losses': 41,
                'draws': 3,
                'winRate': '0.610',
                'gamesBehind': '0.0',
                'battingAverage': '0.279',
                'era': '5.65',
                'runsScored': 598,
                'runsAllowed': 506,
                'recentForm': ['L', 'L', 'W', 'D', 'W'],
              },
            ],
          });
        final dataSource = TeamRemoteDataSourceImpl(dio);

        final teams = await dataSource.getTeams();

        expect(teams, hasLength(1));
        expect(teams.first.teamCode, 'KT');
        expect(teams.first.battingAverage, '0.279');
        expect(teams.first.era, '5.65');
        expect(teams.first.runsScored, 598);
        expect(teams.first.runsAllowed, 506);
      },
    );

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/teams'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = TeamRemoteDataSourceImpl(dio);

      expect(dataSource.getTeams(), throwsA(isA<ServerException>()));
    });
  });

  group('TeamRemoteDataSourceImpl.getTeamDetail', () {
    test(
      'parses a successful /teams/:code response into TeamDetailModel',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = FakeHttpClientAdapter.success({
            'summary': {
              'teamCode': 'KT',
              'teamName': 'kt wiz',
              'rank': 1,
              'wins': 64,
              'losses': 41,
              'draws': 3,
              'winRate': '0.610',
              'gamesBehind': '0.0',
              'battingAverage': '0.279',
              'era': '5.65',
              'runsScored': 598,
              'runsAllowed': 506,
              'recentForm': ['L', 'L', 'W', 'D', 'W'],
            },
            'roster': [
              {
                'id': 'p1',
                'name': '홍길동',
                'teamCode': 'KT',
                'teamName': 'kt wiz',
                'position': 'pitcher',
                'backNumber': 1,
                'primaryStat': '평균자책 3.50',
              },
            ],
          });
        final dataSource = TeamRemoteDataSourceImpl(dio);

        final detail = await dataSource.getTeamDetail('KT');

        expect(detail.summary.teamCode, 'KT');
        expect(detail.roster, hasLength(1));
        expect(detail.roster.first.name, '홍길동');
      },
    );

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/teams/KT'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = TeamRemoteDataSourceImpl(dio);

      expect(dataSource.getTeamDetail('KT'), throwsA(isA<ServerException>()));
    });
  });
}
