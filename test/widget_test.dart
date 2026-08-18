import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jikgwan/app.dart';
import 'package:jikgwan/core/network/network_info.dart';
import 'package:jikgwan/features/example/presentation/screens/example_screen.dart';
import 'package:jikgwan/features/game/data/datasources/game_remote_data_source.dart';
import 'package:jikgwan/features/game/presentation/providers/game_providers.dart';
import 'package:jikgwan/features/standing/data/datasources/standing_remote_data_source.dart';
import 'package:jikgwan/features/standing/presentation/providers/standing_providers.dart';

class _FakeNetworkInfo implements NetworkInfo {
  const _FakeNetworkInfo();

  @override
  Future<bool> get isConnected async => true;
}

void main() {
  testWidgets('shows the home screen on launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // 실제 플러그인(connectivity_plus)의 플랫폼 채널이나 실제 백엔드를 타지
        // 않도록 테스트에서는 NetworkInfo와 game datasource를 오버라이드합니다.
        overrides: [
          networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
          gameRemoteDataSourceProvider.overrideWithValue(
            const GameDummyDataSource(),
          ),
          standingRemoteDataSourceProvider.overrideWithValue(
            const StandingDummyDataSource(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('오늘의 경기'), findsOneWidget);
    expect(find.text('최근 경기 결과'), findsOneWidget);
  });

  testWidgets('shows the KBO team list after loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkInfoProvider.overrideWithValue(const _FakeNetworkInfo()),
          gameRemoteDataSourceProvider.overrideWithValue(
            const GameDummyDataSource(),
          ),
          standingRemoteDataSourceProvider.overrideWithValue(
            const StandingDummyDataSource(),
          ),
        ],
        child: const App(),
      ),
    );

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go(ExampleScreen.routePath);
    await tester.pumpAndSettle();

    expect(find.text('Doosan Bears'), findsOneWidget);
  });
}
