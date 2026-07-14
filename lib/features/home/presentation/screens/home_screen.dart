import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../standing/presentation/screens/standing_screen.dart';
import '../widgets/all_star_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/today_game_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeAppBar(),
              const SizedBox(height: 24),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodayGameSection(),
                      SizedBox(height: 32),
                      AllStarSection(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AppBottomNav(
                activeTab: AppTab.home,
                onHomeTap: () => context.go(HomeScreen.routePath),
                onStatTap: () => context.go(StandingScreen.routePath),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
