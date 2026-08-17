import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/bottom_nav_provider.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../game/presentation/providers/game_providers.dart';
import '../../../home/presentation/screens/home_body.dart';
import '../../../player/presentation/providers/player_providers.dart';
import '../../../record/presentation/providers/record_providers.dart';
import '../../../standing/presentation/providers/standing_providers.dart';
import '../../../standing/presentation/screens/stat_body.dart';
import '../../../team/presentation/providers/team_providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  static const routeName = 'main';
  static const routePath = '/';

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      _refreshData();
    }
  }

  /// 백그라운드에 있다가 다시 포그라운드로 돌아왔을 때 화면에 항상 마운트되어
  /// 있는(IndexedStack) 목록성 provider들을 다시 불러온다.
  void _refreshData() {
    ref.invalidate(todayGamesProvider);
    ref.invalidate(recentFinishedGamesProvider);
    ref.invalidate(standingListProvider);
    ref.invalidate(batterRecordListProvider);
    ref.invalidate(pitcherRecordListProvider);
    ref.invalidate(teamListProvider);
    ref.invalidate(playerListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: activeTab.index,
                  children: const [HomeBody(), StatBody()],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const AppBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
