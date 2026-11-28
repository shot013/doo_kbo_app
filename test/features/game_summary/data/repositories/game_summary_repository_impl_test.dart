import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/error/exceptions.dart';
import 'package:jikgwan/core/error/failures.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/core/utils/result.dart';
import 'package:jikgwan/features/game_summary/data/datasources/game_summary_remote_data_source.dart';
import 'package:jikgwan/features/game_summary/data/models/game_summary_model.dart';
import 'package:jikgwan/features/game_summary/data/repositories/game_summary_repository_impl.dart';
import 'package:jikgwan/features/game_summary/domain/entities/game_summary.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo({required this.connected});

  final bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class _ThrowingDataSource implements GameSummaryRemoteDataSource {
  const _ThrowingDataSource(this.error);

  final Object error;

  @override
  Future<GameSummaryModel> getGameSummary(String gameId) async => throw error;
}

GameSummaryRepositoryImpl _repository(
  GameSummaryRemoteDataSource dataSource, {
  bool connected = true,
}) => GameSummaryRepositoryImpl(
  dataSource,
  _FakeNetworkInfo(connected: connected),
);

const _dummy = GameSummaryDummyDataSource(delay: Duration.zero);

void main() {
  group('GameSummaryRepositoryImpl.getGameSummary', () {
    test('returns the summary', () async {
      final result = await _repository(
        _dummy,
      ).getGameSummary(GameSummaryDummyDataSource.exampleGameId);

      expect(result, isA<Ok<GameSummary>>());
      expect((result as Ok<GameSummary>).value, dummyGameSummary);
    });

    test('maps a missing summary to NotFoundFailure', () async {
      final result = await _repository(_dummy).getGameSummary('20261126SSHT0');

      expect((result as Err<GameSummary>).failure, isA<NotFoundFailure>());
    });

    test(
      'returns NetworkFailure without calling the server when offline',
      () async {
        final result = await _repository(
          const _ThrowingDataSource(ServerException()),
          connected: false,
        ).getGameSummary(GameSummaryDummyDataSource.exampleGameId);

        expect((result as Err<GameSummary>).failure, isA<NetworkFailure>());
      },
    );

    test('maps server and unknown errors', () async {
      final server = await _repository(
        const _ThrowingDataSource(ServerException()),
      ).getGameSummary('x');
      final unknown = await _repository(
        const _ThrowingDataSource(FormatException()),
      ).getGameSummary('x');

      expect((server as Err<GameSummary>).failure, isA<ServerFailure>());
      expect((unknown as Err<GameSummary>).failure, isA<UnknownFailure>());
    });
  });
}
