import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/core/storage/shared_preferences_provider.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/game_summary/presentation/screens/game_summary_screen.dart';
import 'package:jikgwan/features/home/presentation/widgets/recent_game_section.dart';
import 'package:jikgwan/features/home/presentation/widgets/today_game_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

/// HOME 위젯 하나와, 경기 요약 라우트 자리에 받은 `gameId`를 적는 화면만 둔
/// 라우터.
Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  String? favoriteTeamCode,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'favorite_team_code': ?favoriteTeamCode,
  });
  final sharedPreferences = await SharedPreferences.getInstance();

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Scaffold(body: SingleChildScrollView(child: home)),
      ),
      GoRoute(
        path: GameSummaryScreen.routePath,
        name: GameSummaryScreen.routeName,
        builder: (context, state) =>
            Text('summary:${state.uri.queryParameters['gameId']}'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
        gameRemoteDataSourceProvider.overrideWithValue(
          const GameDummyDataSource(),
        ),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty card button opens the game summary (BUG-02)', (
    tester,
  ) async {
    // 더미 오늘 경기에 NC 경기가 없어 빈 카드가 보인다.
    await _pump(tester, const TodayGameSection(), favoriteTeamCode: 'NC');

    await tester.tap(find.text('최근경기 요약 보러가기'));
    await tester.pumpAndSettle();

    expect(find.text('summary:null'), findsOneWidget);
  });

  testWidgets('recent result card opens the summary of that game', (
    tester,
  ) async {
    await _pump(tester, const RecentGameSection());

    await tester.tap(find.text('베스트 활약'));
    await tester.pumpAndSettle();

    expect(find.text('summary:20260713OBLG0'), findsOneWidget);
  });
}
