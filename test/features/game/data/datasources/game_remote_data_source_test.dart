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

  group('GameRemoteDataSourceImpl.getGamePreview', () {
    test(
      'parses a successful /game-previews/:id response into GamePreviewModel',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = FakeHttpClientAdapter.success({
            'gameId': '20260820KTLG0',
            'awayTeamRecord': '53승 46패 4무',
            'awayRecentForm': 'L W W W L',
            'awayTeamEra': '4.04',
            'awayTeamBattingAverage': '0.270',
            'awayTeamAvgRunsScored': '4.7',
            'awayTeamAvgRunsAllowed': '4.6',
            'homeTeamRecord': '60승 37패 2무',
            'homeRecentForm': 'W W L W W',
            'homeTeamEra': '3.65',
            'homeTeamBattingAverage': '0.279',
            'homeTeamAvgRunsScored': '5.4',
            'homeTeamAvgRunsAllowed': '4.1',
            'awayPitcherStyle': '좌완 언더핸드',
            'awayPitcherSeasonRecord': '8승 7패',
            'awayPitcherHeadToHeadRecord': '1승 2패',
            'awayPitcherEra': '3.85',
            'awayPitcherWar': '2.1',
            'awayPitcherGames': '19',
            'awayPitcherAvgInnings': '5.2',
            'awayPitcherQualityStarts': '10',
            'awayPitcherWhip': '1.28',
            'homePitcherStyle': '우완 정통파',
            'homePitcherSeasonRecord': '10승 5패',
            'homePitcherHeadToHeadRecord': '2승 1패',
            'homePitcherEra': '3.10',
            'homePitcherWar': '3.2',
            'homePitcherGames': '20',
            'homePitcherAvgInnings': '6.1',
            'homePitcherQualityStarts': '14',
            'homePitcherWhip': '1.15',
            'scrapedAt': '2026-08-20T00:00:00.000Z',
            'createdAt': '2026-08-20T00:00:00.000Z',
            'updatedAt': '2026-08-20T00:00:00.000Z',
          });
        final dataSource = GameRemoteDataSourceImpl(dio);

        final preview = await dataSource.getGamePreview('20260820KTLG0');

        expect(preview.gameId, '20260820KTLG0');
        expect(preview.homeTeam.record, '60승 37패 2무');
        expect(preview.homeTeam.recentForm, 'W W L W W');
        expect(preview.awayTeam.era, '4.04');
        expect(preview.homePitcher.style, '우완 정통파');
        expect(preview.awayPitcher.whip, '1.28');
      },
    );

    test('throws NotFoundException when the server responds 404', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/game-previews/x'),
            response: Response(
              requestOptions: RequestOptions(path: '/game-previews/x'),
              statusCode: 404,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      final dataSource = GameRemoteDataSourceImpl(dio);

      expect(dataSource.getGamePreview('x'), throwsA(isA<NotFoundException>()));
    });

    test('throws ServerException for other failures', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/game-previews/x'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = GameRemoteDataSourceImpl(dio);

      expect(dataSource.getGamePreview('x'), throwsA(isA<ServerException>()));
    });
  });
}
