import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../game/presentation/providers/game_providers.dart';
import '../../../home/presentation/widgets/home_app_bar.dart';
import '../../../player/presentation/providers/player_providers.dart';
import '../../../record/presentation/providers/record_providers.dart';
import '../../../standing/presentation/providers/standing_providers.dart';
import '../../../team/presentation/providers/team_providers.dart';

/// HOME/순위/기록/팀/선수 5개 탭을 감싸는 셸. go_router의
/// `StatefulShellRoute.indexedStack`가 각 탭을 독립적인 네비게이션 스택으로
/// 관리해주므로, 탭을 넘나들어도(딥링크 포함) 이 셸(BottomNav 포함) 깊이는
/// 유지된다.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
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

  /// 백그라운드에 있다가 다시 포그라운드로 돌아왔을 때 각 탭에 항상
  /// 마운트되어 있는(StatefulShellRoute가 탭마다 상태를 유지) 목록성
  /// provider들을 다시 불러온다.
  void _refreshData() {
    ref.invalidate(todayGamesProvider);
    ref.invalidate(recentGameResultsProvider);
    ref.invalidate(standingListProvider);
    ref.invalidate(batterRecordListProvider);
    ref.invalidate(pitcherRecordListProvider);
    ref.invalidate(teamListProvider);
    ref.invalidate(playerListProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: widget.navigationShell,
        ),
      ),
      floatingActionButton: AppBottomNav(
        navigationShell: widget.navigationShell,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
