import 'package:flutter/material.dart';

/// Centralized palette. Quadrant colors are semantic: red for urgent work
/// that demands action now, blue for important-but-not-urgent planning,
/// amber for delegable interruptions, slate for the discard pile.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF4F5FF7);
  static const Color textPrimary = Color(0xFF1B1D28);
  static const Color textSecondary = Color(0xFF6B6F84);
  static const Color border = Color(0xFFE4E6F0);

  static const Color doFirst = Color(0xFFE5484D);
  static const Color schedule = Color(0xFF3B82F6);
  static const Color delegate = Color(0xFFF59E0B);
  static const Color eliminate = Color(0xFF64748B);
}
