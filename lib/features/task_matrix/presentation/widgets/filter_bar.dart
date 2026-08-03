import 'package:flutter/material.dart';

import '../../../global/constants/app_colors.dart';
import '../../domain/entities/task_priority.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.priorityFilter,
    required this.onSearchChanged,
    required this.onPriorityChanged,
  });

  final TaskPriority? priorityFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskPriority?> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search tasks or tags…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        FilterChip(
          label: const Text('All priorities'),
          selected: priorityFilter == null,
          onSelected: (_) => onPriorityChanged(null),
        ),
        for (final p in TaskPriority.values)
          FilterChip(
            label: Text(p.label),
            selected: priorityFilter == p,
            onSelected: (selected) => onPriorityChanged(selected ? p : null),
          ),
      ],
    );
  }
}
