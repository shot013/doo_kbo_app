import 'package:flutter/material.dart';

import '../widgets/home_app_bar.dart';
import '../widgets/recent_game_section.dart';
import '../widgets/today_game_section.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeAppBar(),
        SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TodayGameSection(),
                SizedBox(height: 32),
                RecentGameSection(),
                SizedBox(height: 32),
                // AllStarSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
