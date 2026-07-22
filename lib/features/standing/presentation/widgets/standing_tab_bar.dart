import 'package:flutter/material.dart';

class StandingTabBar extends StatelessWidget {
  const StandingTabBar({super.key});

  static const _tabs = ['순위', '기록', '팀', '선수'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final tab in _tabs) ...[
          _TabLabel(label: tab, active: tab == _tabs.first),
          const SizedBox(width: 24),
        ],
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
