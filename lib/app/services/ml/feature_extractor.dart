import 'dart:math';

import 'package:ml_linalg/vector.dart';

class FeatureExtractor {
  /// Extract temporal features from a date
  /// Returns a vector with:
  /// [0]: Day of week (0-6 normalized to 0-1)
  /// [1]: Day of month (1-31 normalized to 0-1)
  /// [2]: Month of year (1-12 normalized to 0-1)
  /// [3]: Is weekend (0.0 or 1.0)
  /// [4]: Week of month (0-4 normalized to 0-1)
  Vector extractTemporalFeatures(DateTime date) {
    final dayOfWeek = date.weekday - 1; // 0-6
    final dayOfMonth = date.day - 1; // 0-30
    final month = date.month - 1; // 0-11
    final isWeekend = (date.weekday == 6 || date.weekday == 7) ? 1.0 : 0.0;
    final weekOfMonth = (date.day - 1) ~/ 7;

    return Vector.fromList([
      dayOfWeek / 6.0,
      dayOfMonth / 30.0,
      month / 11.0,
      isWeekend,
      weekOfMonth / 4.0,
    ]);
  }

  /// Extract amount features
  /// [amount]: The transaction amount
  /// [userAvg]: User's average transaction amount (optional)
  /// [categoryAvg]: Category's average transaction amount (optional)
  /// [maxAmount]: Maximum observed amount (for normalization)
  ///
  /// Returns a vector with:
  /// [0]: Log-normalized amount (log(amount + 1))
  /// [1]: Amount bucket (0=small, 1=medium, 2=large, 3=very large)
  /// [2]: Ratio to user average (if provided, else 0)
  /// [3]: Ratio to category average (if provided, else 0)
  Vector extractAmountFeatures(
    double amount,
    String? categoryId,
    Map<String, double> categoryAverages,
    double userAverage,
  ) {
    final logAmount = log(amount + 1);
    
    // Determine bucket
    double bucket = 0.0;
    if (amount > 50000) bucket = 3.0; // Very large
    else if (amount > 20000) bucket = 2.0; // Large
    else if (amount > 5000) bucket = 1.0; // Medium
    // else Small

    double ratioUser = 0.0;
    if (userAverage > 0) {
      ratioUser = amount / userAverage;
      // Cap ratio to avoid outliers skewing too much
      if (ratioUser > 10) ratioUser = 10.0;
    }

    double ratioCategory = 0.0;
    if (categoryId != null && categoryAverages.containsKey(categoryId)) {
      final avg = categoryAverages[categoryId]!;
      if (avg > 0) {
        ratioCategory = amount / avg;
        if (ratioCategory > 10) ratioCategory = 10.0;
      }
    }

    return Vector.fromList([
      logAmount,
      bucket,
      ratioUser,
      ratioCategory,
    ]);
  }

  /// Extract basic text features (simple word presence or length)
  /// More complex TF-IDF should be handled by the model itself or a dedicated preprocessor
  Vector extractTextFeatures(String text) {
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    final length = words.length.toDouble();
    final hasNumbers = text.contains(RegExp(r'[0-9]')) ? 1.0 : 0.0;
    
    // Just some basic structural features
    return Vector.fromList([
      length,
      hasNumbers,
    ]);
  }
}