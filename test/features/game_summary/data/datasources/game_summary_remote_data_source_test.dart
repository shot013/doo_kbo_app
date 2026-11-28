import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/features/game_summary/data/datasources/game_summary_remote_data_source.dart';

import '../../../../support/fake_http_client_adapter.dart';

DioException _badResponse(int statusCode) {
  final requestOptions = RequestOptions(path: '/game-summaries/x');
  return DioException(
    requestOptions: requestOptions,
    response: Response<void>(
      requestOptions: requestOptions,
      statusCode: statusCode,
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('GameSummaryRemoteDataSourceImpl.getGameSummary', () {
    test('parses a successful response', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.success(
          dummyGameSummary.toJson(),
        );

      final summary = await GameSummaryRemoteDataSourceImpl(
        dio,
      ).getGameSummary(GameSummaryDummyDataSource.exampleGameId);

      expect(summary, dummyGameSummary);
    });

    test('throws NotFoundException on 404', () {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(_badResponse(404));

      expect(
        GameSummaryRemoteDataSourceImpl(dio).getGameSummary('20261126SSHT0'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('throws ServerException on other failures', () {
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))
        ..httpClientAdapter = FakeHttpClientAdapter.failure(_badResponse(500));

      expect(
        GameSummaryRemoteDataSourceImpl(dio).getGameSummary('20261126SSHT0'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
