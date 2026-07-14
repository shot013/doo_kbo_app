import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../game/domain/entities/game.dart';
import '../../../game/domain/entities/game_status.dart';
import '../../../game/presentation/providers/game_providers.dart';

class TodayGameSection extends ConsumerWidget {
  const TodayGameSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(todayGamesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _todayLabel(),
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '오늘의 경기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Text(
                  '더보기',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 18),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        gamesAsync.when(
          data: (games) =>
              games.isEmpty ? const _EmptyGameCard() : _GameCard(games.first),
          loading: () => const _GameCardShell(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          error: (error, stackTrace) => _GameCardShell(
            child: Text(
              error is AppFailure ? error.message : '경기 정보를 불러오지 못했습니다.',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  String _todayLabel() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$month.$day (${weekdays[now.weekday - 1]})';
  }
}

class _GameCardShell extends StatelessWidget {
  const _GameCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return _GameCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${game.awayTeamName} vs ${game.homeTeamName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusLabel(game),
            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
          if (game.homeScore != null && game.awayScore != null) ...[
            const SizedBox(height: 12),
            Text(
              '${game.awayScore} : ${game.homeScore}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(Game game) {
    return switch (game.status) {
      GameStatus.scheduled => '경기 예정',
      GameStatus.inProgress => game.currentInning ?? '진행중',
      GameStatus.finished => '경기 종료',
      GameStatus.cancelled => '경기 취소',
      GameStatus.postponed => '경기 연기',
    };
  }
}

class _EmptyGameCard extends StatelessWidget {
  const _EmptyGameCard();

  @override
  Widget build(BuildContext context) {
    return _GameCardShell(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_baseball,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '오늘은 MY팀 경기가 없습니다',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '예정된 경기가 없는 날이에요',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF3A3A3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '최근경기 요약 보러가기',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
