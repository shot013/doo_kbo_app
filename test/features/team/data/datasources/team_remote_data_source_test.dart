import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/team/data/datasources/team_remote_data_source.dart';

/// 실제 HTTP 요청 없이 Dio가 정해진 응답/에러를 받도록 하는 테스트용 어댑터.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter.success(String responseBody)
    : _responseBody = responseBody,
      _error = null;

  _FakeHttpClientAdapter.failure(DioException error)
    : _responseBody = null,
      _error = error;

  final String? _responseBody;
  final DioException? _error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final error = _error;
    if (error != null) throw error;
    return ResponseBody.fromString(
      _responseBody!,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('TeamRemoteDataSourceImpl.getTeams', () {
    test(
      'parses a successful /teams response into TeamSummaryModel list',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'http://test'))
          ..httpClientAdapter = _FakeHttpClientAdapter.success(
            jsonEncode({
              'data': [
                {
                  'code': 'KT',
                  'name': 'kt wiz',
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
            }),
          );
        final dataSource = TeamRemoteDataSourceImpl(dio);

        final teams = await dataSource.getTeams();

        expect(teams, hasLength(1));
        expect(teams.first.code, 'KT');
        expect(teams.first.battingAverage, '0.279');
        expect(teams.first.era, '5.65');
        expect(teams.first.runsScored, 598);
        expect(teams.first.runsAllowed, 506);
      },
    );

    test('throws ServerException when the request fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = _FakeHttpClientAdapter.failure(
          DioException(
            requestOptions: RequestOptions(path: '/teams'),
            type: DioExceptionType.connectionError,
          ),
        );
      final dataSource = TeamRemoteDataSourceImpl(dio);

      expect(dataSource.getTeams(), throwsA(isA<ServerException>()));
    });
  });
}
