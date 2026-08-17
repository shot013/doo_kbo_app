import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/app_bottom_nav.dart';

final bottomNavIndexProvider = NotifierProvider<BottomNavIndexNotifier, AppTab>(
  BottomNavIndexNotifier.new,
);

class BottomNavIndexNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) {
    state = tab;
  }
}
