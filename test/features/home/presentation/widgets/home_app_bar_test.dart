import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jikgwan/core/storage/shared_preferences_provider.dart';
import 'package:jikgwan/core/widgets/team_logo.dart';
import 'package:jikgwan/features/favorite_team/presentation/providers/favorite_team_providers.dart';
import 'package:jikgwan/features/home/presentation/widgets/home_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _wrap() async {
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
    child: const MaterialApp(home: Scaffold(appBar: HomeAppBar())),
  );
}

void main() {
  testWidgets('shows no team logo when no favorite team is set', (
    tester,
  ) async {
    await tester.pumpWidget(await _wrap());
    await tester.pumpAndSettle();

    expect(find.text('직관'), findsOneWidget);
    expect(find.byType(TeamLogo), findsNothing);
  });

  testWidgets('shows the favorite team logo once one is selected', (
    tester,
  ) async {
    final widget = await _wrap();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeAppBar)),
    );
    await container.read(favoriteTeamCodeProvider.notifier).select('KT');
    await tester.pumpAndSettle();

    expect(find.byType(TeamLogo), findsOneWidget);
  });
}
