import 'package:flutter/material.dart';

import '../../../global/constants/app_colors.dart';
import '../../../global/constants/app_text_styles.dart';
import '../../../task_matrix/domain/entities/quadrant.dart';
import '../../../task_matrix/presentation/widgets/quadrant_x.dart';
import '../../domain/entities/dump_entry.dart';
import 'quadrant_picker.dart';

class DumpEntryRow extends StatelessWidget {
  const DumpEntryRow({
    super.key,
    required this.entry,
    required this.selected,
    required this.onSelected,
    required this.onDiscard,
    this.enabled = true,
  });

  final DumpEntry entry;
  final Quadrant? selected;
  final ValueChanged<Quadrant> onSelected;
  final VoidCallback onDiscard;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = selected?.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent ?? AppColors.border,
          width: accent == null ? 1 : 1.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final text = Text(entry.text, style: AppTextStyles.body);
          final picker = QuadrantPicker(
            selected: selected,
            onSelected: onSelected,
            compact: constraints.maxWidth < 560,
            enabled: enabled,
          );
          final discard = IconButton(
            onPressed: enabled ? onDiscard : null,
            icon: const Icon(Icons.close_rounded, size: 18),
            tooltip: 'Remove from dump',
            color: AppColors.textSecondary,
            visualDensity: VisualDensity.compact,
          );

          // Below this width the buttons and the text can't share a line
          // without the text being squeezed to a few characters.
          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: text), discard],
                ),
                const SizedBox(height: 8),
                picker,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 12),
              picker,
              discard,
            ],
          );
        },
      ),
    );
  }
}
