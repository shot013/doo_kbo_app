import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/game/presentation/screens/game_preview_screen.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
      gameRemoteDataSourceProvider.overrideWithValue(
        const GameDummyDataSource(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('shows team comparison and pitcher matchup for a known game', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const GamePreviewScreen(gameId: '20260713OBLG0')),
    );
    await tester.pumpAndSettle();

    expect(find.text('팀 전력비교'), findsOneWidget);
    expect(find.text('선발투수 매치업'), findsOneWidget);
    expect(find.text('우완 정통파'), findsOneWidget);
  });

  testWidgets('shows a friendly message when no preview exists yet', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const GamePreviewScreen(gameId: 'unknown')));
    await tester.pumpAndSettle();

    expect(find.text('아직 이 경기의 프리뷰 정보가 없습니다.'), findsOneWidget);
  });
}
