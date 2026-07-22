import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/bottom_nav_provider.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../home/presentation/screens/home_body.dart';
import '../../../standing/presentation/screens/stat_body.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const routeName = 'main';
  static const routePath = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: const AppBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
