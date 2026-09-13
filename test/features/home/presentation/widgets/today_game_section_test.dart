import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/core/storage/shared_preferences_provider.dart';
import 'package:jikgwan/features/favorite_team/presentation/providers/favorite_team_providers.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/home/presentation/widgets/today_game_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

Future<Widget> _wrap() async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [
      networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
      gameRemoteDataSourceProvider.overrideWithValue(
        const GameDummyDataSource(),
      ),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const MaterialApp(home: Scaffold(body: TodayGameSection())),
  );
}

void main() {
  testWidgets('shows today\'s games with starter pitchers', (tester) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('오늘의 경기'), findsOneWidget);
    expect(find.text('LG'), findsOneWidget);
    expect(find.text('두산'), findsOneWidget);
  });

  testWidgets('filters to only the favorite team\'s game when one is set', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TodayGameSection)),
    );
    await container.read(favoriteTeamCodeProvider.notifier).select('SS');
    await tester.pumpAndSettle();

    expect(find.text('SSG'), findsOneWidget);
    expect(find.text('KIA'), findsOneWidget);
    expect(find.text('LG'), findsNothing);
    expect(find.text('두산'), findsNothing);
  });

  testWidgets('shows every game again after the favorite team is cleared', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TodayGameSection)),
    );
    await container.read(favoriteTeamCodeProvider.notifier).select('SS');
    await tester.pumpAndSettle();
    await container.read(favoriteTeamCodeProvider.notifier).select(null);
    await tester.pumpAndSettle();

    expect(find.text('LG'), findsOneWidget);
    expect(find.text('두산'), findsOneWidget);
    expect(find.text('SSG'), findsOneWidget);
    expect(find.text('KIA'), findsOneWidget);
  });
}
