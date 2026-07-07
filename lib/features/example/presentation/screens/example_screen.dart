import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../providers/team_providers.dart';

class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  static const routeName = 'example';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('KBO Teams (Example)')),
      body: teamsAsync.when(
        data: (teams) => ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return ListTile(title: Text(team.name), subtitle: Text(team.city));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(error is AppFailure ? error.message : '오류가 발생했습니다.'),
        ),
      ),
    );
  }
}
