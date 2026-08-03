import 'package:flutter/material.dart';

import '../../../global/constants/app_colors.dart';
import '../../domain/entities/quadrant.dart';

/// Presentation-only mapping of a domain [Quadrant] to its visual identity.
/// Kept out of the domain layer, which stays free of Flutter dependencies.
extension QuadrantX on Quadrant {
  Color get color {
    switch (this) {
      case Quadrant.doFirst:
        return AppColors.doFirst;
      case Quadrant.schedule:
        return AppColors.schedule;
      case Quadrant.delegate:
        return AppColors.delegate;
      case Quadrant.eliminate:
        return AppColors.eliminate;
    }
  }

  IconData get icon {
    switch (this) {
      case Quadrant.doFirst:
        return Icons.bolt_rounded;
      case Quadrant.schedule:
        return Icons.event_available_rounded;
      case Quadrant.delegate:
        return Icons.forward_to_inbox_rounded;
      case Quadrant.eliminate:
        return Icons.delete_outline_rounded;
    }
  }
}
