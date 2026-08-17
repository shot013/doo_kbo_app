import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        _ToggleChip(
          label: '타자 기록',
          active: active == RecordCategory.batting,
          onTap: () => notifier.select(RecordCategory.batting),
        ),
        const SizedBox(width: 8),
        _ToggleChip(
          label: '투수 기록',
          active: active == RecordCategory.pitching,
          onTap: () => notifier.select(RecordCategory.pitching),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4ADE80) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : const Color(0xFF9E9E9E),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
