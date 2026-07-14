import 'package:flutter/material.dart';

enum AppTab { home, stat }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onHomeTap,
    required this.onStatTap,
  });

  final AppTab activeTab;
  final VoidCallback onHomeTap;
  final VoidCallback onStatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home,
            label: 'HOME',
            active: activeTab == AppTab.home,
            onTap: onHomeTap,
          ),
          const Icon(Icons.donut_large, color: Color(0xFF9E9E9E)),
          _NavItem(
            icon: Icons.bar_chart,
            label: 'STAT',
            active: activeTab == AppTab.stat,
            onTap: onStatTap,
          ),
          const Icon(Icons.person_outline, color: Color(0xFF9E9E9E)),
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
        icon: Icon(icon, color: const Color(0xFF9E9E9E)),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
