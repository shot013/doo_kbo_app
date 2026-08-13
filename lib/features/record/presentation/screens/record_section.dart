import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/widgets/bottom_nav_spacer.dart';
import '../../domain/entities/record_category.dart';
import '../providers/record_providers.dart';
import '../widgets/batter_record_table.dart';
import '../widgets/pitcher_record_table.dart';
import '../widgets/record_category_toggle.dart';

class RecordSection extends ConsumerWidget {
  const RecordSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(recordCategoryProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기록',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const RecordCategoryToggle(),
          const SizedBox(height: 20),
          switch (category) {
            RecordCategory.batting => const _BatterLeaderboard(),
            RecordCategory.pitching => const _PitcherLeaderboard(),
          },
          const BottomNavSpacer(),
        ],
      ),
    );
  }
}

class _BatterLeaderboard extends ConsumerWidget {
  const _BatterLeaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(batterRecordListProvider);

    return recordsAsync.when(
      data: (records) => BatterRecordTable(records: records),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            error is AppFailure ? error.message : '기록 정보를 불러오지 못했습니다.',
            style: const TextStyle(color: Color(0xFF9E9E9E)),
          ),
        ),
      ),
    );
  }
}

class _PitcherLeaderboard extends ConsumerWidget {
  const _PitcherLeaderboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(pitcherRecordListProvider);

    return recordsAsync.when(
      data: (records) => PitcherRecordTable(records: records),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            error is AppFailure ? error.message : '기록 정보를 불러오지 못했습니다.',
            style: const TextStyle(color: Color(0xFF9E9E9E)),
          ),
        ),
      ),
    );
  }
}
