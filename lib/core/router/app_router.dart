import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/presentation/screens/example_screen.dart';
import '../../features/game/presentation/screens/game_detail_screen.dart';
import '../../features/game/presentation/screens/game_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/standing/presentation/screens/standing_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomeScreen.routePath,
    routes: [
      GoRoute(
        path: HomeScreen.routePath,
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
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
        path: StandingScreen.routePath,
        name: StandingScreen.routeName,
        builder: (context, state) => const StandingScreen(),
      ),
    ],
  );
});
