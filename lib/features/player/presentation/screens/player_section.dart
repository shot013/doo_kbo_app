import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/player_position.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/bottom_nav_spacer.dart';
import '../../../../core/widgets/player_list_row.dart';
import '../providers/player_providers.dart';
import 'player_detail_screen.dart';

class PlayerSection extends ConsumerWidget {
  const PlayerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(filteredPlayersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '선수',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        const _PlayerSearchField(),
        const SizedBox(height: 12),
        const _PositionFilterChips(),
        const SizedBox(height: 12),
        Expanded(
          child: playersAsync.when(
            data: (players) => players.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        '검색 결과가 없습니다.',
                        style: TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      for (final player in players)
                        PlayerListRow(
                          name: player.name,
                          teamCode: player.teamCode,
                          position: player.position,
                          backNumber: player.backNumber,
                          trailingText: player.primaryStat,
                          subtitle:
                              '${player.teamName} · ${player.position.displayName}',
                          showTeamLogo: true,
                          onTap: () => context.pushNamed(
                            PlayerDetailScreen.routeName,
                            pathParameters: {'id': player.id},
                          ),
                        ),
                      const BottomNavSpacer(),
                    ],
                  ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                error is AppFailure ? error.message : '선수 정보를 불러오지 못했습니다.',
                style: const TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerSearchField extends ConsumerWidget {
  const _PlayerSearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      onChanged: (value) =>
          ref.read(playerSearchQueryProvider.notifier).update(value),
      decoration: InputDecoration(
        hintText: '선수 또는 팀 이름 검색',
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PositionFilterChips extends ConsumerWidget {
  const _PositionFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(playerPositionFilterProvider);
    final notifier = ref.read(playerPositionFilterProvider.notifier);

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: '전체',
            active: selected == null,
            onTap: () => notifier.select(null),
          ),
          for (final position in PlayerPosition.values) ...[
            const SizedBox(width: 8),
            _FilterChip(
              label: position.displayName,
              active: selected == position,
              onTap: () => notifier.select(position),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4ADE80) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : const Color(0xFF9E9E9E),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
