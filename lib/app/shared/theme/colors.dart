import 'package:flutter/material.dart';

/// Centralized color palette for Koala app, following accessibility and brand guidelines.
class AppColors {
  static const Color primary = Color(0xFF059669); // Green, main brand color
  static const Color accent = Color(0xFF3B82F6); // Blue, secondary accent
  static const Color surface = Color(0xFFFAFBFC); // Light background
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Slightly darker background
  static const Color error = Color(0xFFEF4444); // Red, error
  static const Color onPrimary = Colors.white; // Text on primary
  static const Color onSurface = Color(0xFF334155); // Text on surface
  static const Color onSurfaceVariant = Color(0xFF64748B); // Muted text
  static const Color success = Color(0xFF10B981); // Success green
  static const Color warning = Color(0xFFF59E0B); // Warning yellow
  static const Color textInverse = Colors.white; // For text on dark backgrounds
  static const Color interactiveDisabled = Color(
    0xFFE2E8F0,
  ); // Disabled button bg
  static const Color textDisabled = Color(0xFF94A3B8); // Disabled button text
  static const Color border = Color(
    0xFFE2E8F0,
  ); // Border color for inputs, pins
}
