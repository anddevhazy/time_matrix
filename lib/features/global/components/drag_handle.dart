import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// The grip icon that starts a reorder drag for the item at [index] in the
/// nearest [ReorderableListView]. Only the handle starts a reorder, so taps
/// and other drags on the rest of the row keep working.
class DragHandle extends StatelessWidget {
  const DragHandle({super.key, required this.index, this.enabled = true});

  final int index;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.grab : SystemMouseCursors.basic,
        child: Tooltip(
          message: 'Drag to reorder',
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.drag_handle_rounded,
              size: 20,
              color: AppColors.textSecondary.withValues(alpha: enabled ? 1 : 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lifts the dragged row without the default rectangular Material shadow,
/// which doesn't match the rounded cards.
Widget reorderProxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Transform.scale(
      scale: 1 + 0.02 * Curves.easeOut.transform(animation.value),
      child: Material(type: MaterialType.transparency, child: child),
    ),
    child: child,
  );
}
