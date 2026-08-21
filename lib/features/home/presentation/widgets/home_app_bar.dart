import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC72C),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sports_baseball,
            color: Colors.black,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'JIKGWAN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
