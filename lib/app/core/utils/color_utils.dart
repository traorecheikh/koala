import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  /// Calculates the contrast ratio between two colors using WCAG 2.0 formula.
  /// Returns a value between 1.0 and 21.0.
  static double calculateContrast(Color c1, Color c2) {
    final double lum1 = c1.computeLuminance();
    final double lum2 = c2.computeLuminance();
    return (max(lum1, lum2) + 0.05) / (min(lum1, lum2) + 0.05);
  }

  /// Returns White or Black depending on which has better contrast against [background].
  /// This is the standard way to determine text color on a dynamic background.
  static Color getLegibleOn(Color background) {
    final double contrastFirst = calculateContrast(Colors.white, background);
    final double contrastSecond = calculateContrast(Colors.black, background);

    return contrastFirst >= contrastSecond ? Colors.white : Colors.black;
  }

  /// Ensures that [foreground] has at least [minRatio] contrast against [background].
  /// If it doesn't, it returns either White or Black, whichever is better.
  ///
  /// Usage:
  /// ```dart
  /// final safeColor = ColorUtils.ensureContrast(myColor, myBackground);
  /// ```
  static Color ensureContrast(Color foreground, Color background,
      {double minRatio = 4.5}) {
    if (calculateContrast(foreground, background) >= minRatio) {
      return foreground;
    }
    return getLegibleOn(background);
  }
}
