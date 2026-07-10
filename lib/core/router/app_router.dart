import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/example/presentation/screens/example_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

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
    ],
  );
});
