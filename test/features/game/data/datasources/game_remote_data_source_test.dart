import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';

import '../../../../support/fake_http_client_adapter.dart';

void main() {
  group('GameRemoteDataSourceImpl.getGames', () {
    test('parses a successful /games response into GameModel list', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success({
          'data': [
            {
              'id': '20260820KTLG0',
              'seasonYear': 2026,
              'gameDate': '2026-08-20',
              'scheduledAt': '2026-08-20T10:00:00.000Z',
              'stadium': '잠실',
              'homeTeamCode': 'LG',
              'homeTeamName': 'LG 트윈스',
              'awayTeamCode': 'KT',
              'awayTeamName': 'kt wiz',
              'homeScore': 4,
              'awayScore': 16,
              'homeStarterPitcher': '박시원',
              'awayStarterPitcher': '고영표',
              'currentInning': null,
              'status': 'FINISHED',
            },
          ],
        });
      final dataSource = GameRemoteDataSourceImpl(dio);

      final games = await dataSource.getGames();

      expect(games, hasLength(1));
      expect(games.first.id, '20260820KTLG0');
      expect(games.first.homeStarterPitcher, '박시원');
    });

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/games'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = GameRemoteDataSourceImpl(dio);

      expect(dataSource.getGames(), throwsA(isA<ServerException>()));
    });
  });

  group('GameRemoteDataSourceImpl.getGameStats', () {
    test(
      'parses a successful /game-stats response into GameStatModel list',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = FakeHttpClientAdapter.success({
            'data': [
              {
                'id': 1,
                'gameId': '20260820KTLG0',
                'teamCode': 'KT',
                'playerName': '강백호',
                'playerNo': '50',
                'statType': 'BATTING',
                'atBats': 4,
                'hits': 2,
                'doubles': null,
                'triples': null,
                'homeRuns': null,
                'rbi': 1,
                'runs': 1,
                'walks': null,
                'strikeouts': null,
                'stolenBases': null,
                'battingAverage': '0.500',
                'inningsPitched': null,
                'hitsAllowed': null,
                'earnedRuns': null,
                'strikeoutsPitched': null,
                'walksAllowed': null,
                'homeRunsAllowed': null,
                'win': false,
                'loss': false,
                'save': false,
                'hold': false,
                'era': null,
              },
            ],
          });
        final dataSource = GameRemoteDataSourceImpl(dio);

        final stats = await dataSource.getGameStats('20260820KTLG0');

        expect(stats, hasLength(1));
        expect(stats.first.playerName, '강백호');
      },
    );
  });

  group('GameRemoteDataSourceImpl.getRecentGameResults', () {
    test('parses the "games" envelope key (not "data")', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success({
          'gameDate': '2026-08-20',
          'games': [
            {
              'gameId': '20260820KTLG0',
              'gameDate': '2026-08-20',
              'stadium': '잠실',
              'homeTeamCode': 'LG',
              'homeTeamName': 'LG 트윈스',
              'awayTeamCode': 'KT',
              'awayTeamName': 'kt wiz',
              'homeScore': 4,
              'awayScore': 16,
              'bestPerformer': null,
              'pitchers': <Map<String, dynamic>>[],
            },
          ],
        });
      final dataSource = GameRemoteDataSourceImpl(dio);

      final results = await dataSource.getRecentGameResults();

      expect(results, hasLength(1));
      expect(results.first.gameId, '20260820KTLG0');
    });
  });
}
