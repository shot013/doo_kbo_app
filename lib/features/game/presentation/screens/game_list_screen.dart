import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_status.dart';
import '../providers/game_providers.dart';
import 'game_detail_screen.dart';

class GameListScreen extends ConsumerWidget {
  const GameListScreen({super.key});

  static const routeName = 'games';
  static const routePath = '/games';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gameListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('경기 일정')),
      body: gamesAsync.when(
        data: (games) => ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return ListTile(
              title: Text('${game.awayTeamName} vs ${game.homeTeamName}'),
              subtitle: Text(_statusLabel(game)),
              trailing: Text(_scoreLabel(game)),
              onTap: () => context.pushNamed(
                GameDetailScreen.routeName,
                pathParameters: {'id': game.id},
              ),
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

  String _statusLabel(Game game) {
    return switch (game.status) {
      GameStatus.scheduled => '예정',
      GameStatus.inProgress => game.currentInning ?? '진행중',
      GameStatus.finished => '종료',
      GameStatus.cancelled => '취소',
      GameStatus.postponed => '연기',
    };
  }

  String _scoreLabel(Game game) {
    if (game.homeScore == null || game.awayScore == null) return 'vs';
    return '${game.awayScore} : ${game.homeScore}';
  }
}
