import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/home/presentation/widgets/today_game_section.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets('shows today\'s games with starter pitchers', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
          gameRemoteDataSourceProvider.overrideWithValue(
            const GameDummyDataSource(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TodayGameSection())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 경기'), findsOneWidget);
    expect(find.text('LG'), findsOneWidget);
    expect(find.text('두산'), findsOneWidget);
  });
}
