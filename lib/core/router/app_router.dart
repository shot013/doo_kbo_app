import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/presentation/screens/example_screen.dart';
import '../../features/game/presentation/screens/game_detail_screen.dart';
import '../../features/game/presentation/screens/game_list_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/player/presentation/screens/player_detail_screen.dart';
import '../../features/team/presentation/screens/team_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: MainScreen.routePath,
    // Home <-> STAT, STAT 내부 탭 전환은 go_router가 아니라 Riverpod 상태
    // 전환이라 여기(페이지=라우트 이동)에는 안 잡힌다.
    observers: [_RouteLoggingObserver()],
    routes: [
      GoRoute(
        path: MainScreen.routePath,
        name: MainScreen.routeName,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: ExampleScreen.routePath,
        name: ExampleScreen.routeName,
        builder: (context, state) => const ExampleScreen(),
      ),
      GoRoute(
        path: GameListScreen.routePath,
        name: GameListScreen.routeName,
        builder: (context, state) => const GameListScreen(),
      ),
      GoRoute(
        path: GameDetailScreen.routePath,
        name: GameDetailScreen.routeName,
        builder: (context, state) =>
            GameDetailScreen(gameId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: TeamDetailScreen.routePath,
        name: TeamDetailScreen.routeName,
        builder: (context, state) =>
            TeamDetailScreen(teamCode: state.pathParameters['code']!),
      ),
      GoRoute(
        path: PlayerDetailScreen.routePath,
        name: PlayerDetailScreen.routeName,
        builder: (context, state) =>
            PlayerDetailScreen(playerId: state.pathParameters['id']!),
      ),
    ],
  );
});

/// 페이지(라우트)가 바뀔 때마다 콘솔에 로그를 남긴다.
class _RouteLoggingObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('push', from: previousRoute, to: route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('pop', from: route, to: previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('replace', from: oldRoute, to: newRoute);
  }

  void _log(
    String action, {
    required Route<dynamic>? from,
    required Route<dynamic>? to,
  }) {
    debugPrint(
      '[route] $action: ${from?.settings.name ?? '(none)'} -> ${to?.settings.name ?? '(none)'}',
    );
  }
}
