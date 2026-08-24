import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/home/presentation/widgets/recent_game_section.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets(
    'shows the best performer and pitcher decisions for the latest result',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
            gameRemoteDataSourceProvider.overrideWithValue(
              const GameDummyDataSource(),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: RecentGameSection())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('최근 경기 결과'), findsOneWidget);
      expect(find.text('베스트 활약'), findsOneWidget);
      expect(find.textContaining('김민석'), findsOneWidget);
      expect(find.textContaining('이민호'), findsOneWidget);
    },
  );
}
