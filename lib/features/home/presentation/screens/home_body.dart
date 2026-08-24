import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/bottom_nav_spacer.dart';
import '../../../game/presentation/providers/game_providers.dart';
import '../widgets/recent_game_section.dart';
import '../widgets/today_game_section.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(todayGamesProvider);
                  ref.invalidate(recentGameResultsProvider);
                },
                child: const SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TodayGameSection(),
                      SizedBox(height: 24),
                      RecentGameSection(),
                      BottomNavSpacer(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
