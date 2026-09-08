import 'package:flutter/material.dart';

import '../../../global/constants/app_text_styles.dart';
import '../../../task_matrix/domain/entities/quadrant.dart';
import '../../../task_matrix/presentation/widgets/quadrant_x.dart';

/// The four quick-assign buttons shown against a dump entry. Selection is a
/// staged intent, not a write — tapping the active quadrant again clears it.
class QuadrantPicker extends StatelessWidget {
  const QuadrantPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.compact = false,
    this.enabled = true,
  });

  final Quadrant? selected;
  final ValueChanged<Quadrant> onSelected;

  /// Drops the labels and keeps only the icons, for narrow rows.
  final bool compact;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final quadrant in Quadrant.values)
          _QuadrantButton(
            quadrant: quadrant,
            isSelected: selected == quadrant,
            compact: compact,
            onPressed: enabled ? () => onSelected(quadrant) : null,
          ),
      ],
    );
  }
}

class _QuadrantButton extends StatelessWidget {
  const _QuadrantButton({
    required this.quadrant,
    required this.isSelected,
    required this.compact,
    required this.onPressed,
  });

  final Quadrant quadrant;
  final bool isSelected;
  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = quadrant.color;
    final foreground = isSelected ? Colors.white : color;

    return Tooltip(
      message: isSelected
          ? 'Clear ${quadrant.title}'
          : 'Move to ${quadrant.title} — ${quadrant.subtitle}',
      child: Material(
        color: isSelected ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(quadrant.icon, size: 15, color: foreground),
                if (!compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    quadrant.title,
                    softWrap: false,
                    style: AppTextStyles.caption.copyWith(color: foreground),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
