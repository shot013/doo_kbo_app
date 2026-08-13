import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stat_tab_provider.dart';

class StatTabBar extends ConsumerWidget {
  const StatTabBar({super.key});

  static const _labels = {
    StatTab.standing: '순위',
    StatTab.record: '기록',
    StatTab.team: '팀',
    StatTab.player: '선수',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(statTabProvider);
    final notifier = ref.read(statTabProvider.notifier);

    return Row(
      children: [
        for (final entry in _labels.entries) ...[
          _TabLabel(
            label: entry.value,
            active: entry.key == activeTab,
            onTap: () => notifier.select(entry.key),
          ),
          const SizedBox(width: 24),
        ],
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF9E9E9E),
              fontSize: 16,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 28,
            color: active ? const Color(0xFF4ADE80) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
