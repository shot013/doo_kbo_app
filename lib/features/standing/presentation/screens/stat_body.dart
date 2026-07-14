import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../providers/standing_providers.dart';
import '../widgets/standing_tab_bar.dart';
import '../widgets/standing_table.dart';
import '../widgets/stat_app_bar.dart';

class StatBody extends ConsumerWidget {
  const StatBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(standingListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatAppBar(),
        const SizedBox(height: 24),
        const StandingTabBar(),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StandingHeader(),
                const SizedBox(height: 16),
                standingsAsync.when(
                  data: (standings) => StandingTable(standings: standings),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  error: (error, stackTrace) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        error is AppFailure
                            ? error.message
                            : '순위 정보를 불러오지 못했습니다.',
                        style: const TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StandingHeader extends StatelessWidget {
  const _StandingHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '순위',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          children: [
            _DropdownLabel('2026'),
            SizedBox(width: 12),
            _DropdownLabel('정규시즌'),
          ],
        ),
      ],
    );
  }
}

class _DropdownLabel extends StatelessWidget {
  const _DropdownLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        ),
        const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF9E9E9E),
          size: 18,
        ),
      ],
    );
  }
}
