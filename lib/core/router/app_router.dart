import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/presentation/screens/example_screen.dart';
import '../../features/game/presentation/screens/game_detail_screen.dart';
import '../../features/game/presentation/screens/game_list_screen.dart';
import '../../features/home/presentation/screens/home_body.dart';
import '../../features/main/presentation/screens/main_shell.dart';
import '../../features/player/presentation/screens/player_detail_screen.dart';
import '../../features/player/presentation/screens/player_section.dart';
import '../../features/record/presentation/screens/record_section.dart';
import '../../features/standing/presentation/screens/standing_section.dart';
import '../../features/team/presentation/screens/team_detail_screen.dart';
import '../../features/team/presentation/screens/team_section.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    observers: [_RouteLoggingObserver()],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeBody(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/standings',
                name: 'standings',
                builder: (context, state) => const StandingSection(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/records',
                name: 'records',
                builder: (context, state) => const RecordSection(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/teams',
                name: 'teams',
                builder: (context, state) => const TeamSection(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/players',
                name: 'players',
                builder: (context, state) => const PlayerSection(),
              ),
            ],
          ),
        ],
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
