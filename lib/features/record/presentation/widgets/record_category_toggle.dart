import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/toggle_chip.dart';
import '../../domain/entities/record_category.dart';
import '../providers/record_providers.dart';

class RecordCategoryToggle extends ConsumerWidget {
  const RecordCategoryToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(recordCategoryProvider);
    final notifier = ref.read(recordCategoryProvider.notifier);

    return Row(
      children: [
        ToggleChip(
          label: '타자 기록',
          active: active == RecordCategory.batting,
          onTap: () => notifier.select(RecordCategory.batting),
        ),
        const SizedBox(width: 8),
        ToggleChip(
          label: '투수 기록',
          active: active == RecordCategory.pitching,
          onTap: () => notifier.select(RecordCategory.pitching),
        ),
      ],
    );
  }
}
