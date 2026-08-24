import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(36);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leadingWidth: 50,
      titleSpacing: 0,
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFFFC72C),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.sports_baseball, color: Colors.black, size: 20),
      ),
      title: const Text(
        '직관',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          height: 1.0,
        ),
      ),
    );
  }
}
