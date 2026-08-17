import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/stat_tab_provider.dart';
import '../../../../core/widgets/stat_app_bar.dart';
import '../../../../core/widgets/stat_tab_bar.dart';
import '../../../player/presentation/screens/player_section.dart';
import '../../../record/presentation/screens/record_section.dart';
import '../../../team/presentation/screens/team_section.dart';
import 'standing_section.dart';

class StatBody extends ConsumerWidget {
  const StatBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(statTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatAppBar(),
        const SizedBox(height: 24),
        const StatTabBar(),
        const SizedBox(height: 24),
        Expanded(
          child: switch (activeTab) {
            StatTab.standing => const StandingSection(),
            StatTab.record => const RecordSection(),
            StatTab.team => const TeamSection(),
            StatTab.player => const PlayerSection(),
          },
        ),
      ],
    );
  }
}
