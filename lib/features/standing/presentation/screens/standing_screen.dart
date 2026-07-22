import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../providers/standing_providers.dart';

class StandingScreen extends ConsumerWidget {
  const StandingScreen({super.key});

  static const routeName = 'standings';
  static const routePath = '/standings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('팀 순위')),
      body: standingsAsync.when(
        data: (standings) => ListView.builder(
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final standing = standings[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${standing.rank}')),
              title: Text(standing.teamName),
              subtitle: Text(
                '${standing.wins}승 ${standing.losses}패 ${standing.draws}무 · ${standing.last10 ?? '-'}',
              ),
              trailing: Text(standing.winRate),
            );
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
