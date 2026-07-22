import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/presentation/screens/example_screen.dart';
import '../../features/game/presentation/screens/game_detail_screen.dart';
import '../../features/game/presentation/screens/game_list_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: MainScreen.routePath,
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
    ],
  );
});
