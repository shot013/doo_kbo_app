import 'package:flutter/material.dart';

import '../widgets/all_star_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/today_game_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAppBar(),
              SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodayGameSection(dateLabel: '07.10 (금)'),
                      SizedBox(height: 32),
                      AllStarSection(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              HomeBottomNav(),
            ],
          ),
        ),
      ),
    );
  }
}
