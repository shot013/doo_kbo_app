import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _NavTab {
  const _NavTab(this.icon, this.label);

  final IconData icon;
  final String label;
}

const _tabs = [
  _NavTab(Icons.home, 'HOME'),
  _NavTab(Icons.emoji_events, '순위'),
  _NavTab(Icons.bar_chart, '기록'),
  _NavTab(Icons.groups, '팀'),
  _NavTab(Icons.person, '선수'),
];

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _tabs.length; i++) ...[
            if (i != 0) const SizedBox(width: 2),
            _NavItem(
              icon: _tabs[i].icon,
              label: _tabs[i].label,
              active: navigationShell.currentIndex == i,
              onTap: () => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return IconButton(
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, color: const Color(0xFF9E9E9E), size: 20),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF4ADE80),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
