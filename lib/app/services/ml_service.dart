import 'dart:math';

import 'package:koaa/app/data/models/local_transaction.dart';

/// Lightweight DTO for isolate communication (HiveObject can't be sent to isolates)
class TransactionData {
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;

  TransactionData({
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  factory TransactionData.fromTransaction(LocalTransaction tx) {
    return TransactionData(
      amount: tx.amount,
      date: tx.date,
      type: tx.type,
      category: tx.category ?? TransactionCategory.otherExpense,
    );
  }
}

/// Local Machine Learning Service for financial insights and predictions
/// Uses simple but effective algorithms for pattern detection and forecasting
class MLService {
  // Cache for expensive computations
  String? _lastTransactionHash;
  List<MLInsight>? _cachedInsights;
  SpendingPattern? _cachedPattern;
  Map<DateTime, double>? _cachedPredictions;

  /// Generate a simple hash of transactions for cache invalidation
  String _hashTransactions(List<LocalTransaction> transactions) {
    if (transactions.isEmpty) return 'empty';
    final first = transactions.first;
    final last = transactions.last;
    return '${transactions.length}_${first.date.millisecondsSinceEpoch}_${last.date.millisecondsSinceEpoch}_${first.amount}_${last.amount}';
  }

  /// Predict next 7 days spending based on historical patterns
  Map<DateTime, double> predictNextWeekSpending(
    List<LocalTransaction> transactions,
  ) {
    final hash = _hashTransactions(transactions);
    if (hash == _lastTransactionHash && _cachedPredictions != null) {
      return _cachedPredictions!;
    }

    if (transactions.isEmpty) return {};

    final predictions = <DateTime, double>{};
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) return {};

    // Calculate daily averages for each day of week
    final dayOfWeekAverages = <int, List<double>>{};
    for (var tx in expenses) {
      final day = tx.date.weekday;
      dayOfWeekAverages.putIfAbsent(day, () => []).add(tx.amount);
    }

    // Calculate weighted moving average for each day
    final dayAverages = <int, double>{};
    dayOfWeekAverages.forEach((day, amounts) {
      // Give more weight to recent transactions
      amounts.sort();
      final recentWeight = amounts.length > 5 ? 0.6 : 0.5;
      final recent = amounts.sublist(max(0, amounts.length - 5));
      final older = amounts.length > 5
          ? amounts.sublist(0, amounts.length - 5)
          : <double>[];

      final recentAvg = recent.isEmpty
          ? 0.0
          : recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.isEmpty
          ? 0.0
          : older.reduce((a, b) => a + b) / older.length;

      dayAverages[day] =
          (recentAvg * recentWeight) + (olderAvg * (1 - recentWeight));
    });

    // Generate predictions for next 7 days
    final now = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      final dayOfWeek = date.weekday;
      final avgSpending = dayAverages[dayOfWeek] ?? 0.0;

      // Add slight randomness based on historical variance
      final variance = _calculateVariance(dayOfWeekAverages[dayOfWeek] ?? []);
      final noise = (Random().nextDouble() - 0.5) * variance * 0.3;

      predictions[DateTime(date.year, date.month, date.day)] = max(
        0,
        avgSpending + noise,
      );
    }

    _lastTransactionHash = hash;
    _cachedPredictions = predictions;
    return predictions;
  }

  /// Detect spending anomalies using statistical analysis
  List<SpendingAnomaly> detectAnomalies(List<LocalTransaction> transactions) {
    final anomalies = <SpendingAnomaly>[];
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenses.length < 10) return anomalies; // Need sufficient data

    // Group by category - handle nullable categories
    final categoryGroups = <TransactionCategory, List<double>>{};
    for (var tx in expenses) {
      final category = tx.category ?? TransactionCategory.otherExpense;
      categoryGroups.putIfAbsent(category, () => []).add(tx.amount);
    }

    // Detect anomalies per category using Z-score
    categoryGroups.forEach((category, amounts) {
      if (amounts.length < 5) return;

      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = _calculateVariance(amounts);
      final stdDev = sqrt(variance);

      for (int i = 0; i < min(5, amounts.length); i++) {
        final amount = amounts[amounts.length - 1 - i];
        final zScore = (amount - mean) / stdDev;

        if (zScore.abs() > 2.0) {
          // Beyond 2 standard deviations
          anomalies.add(
            SpendingAnomaly(
              category: category,
              amount: amount,
              expectedAmount: mean,
              severity: zScore.abs() > 3.0
                  ? AnomalySeverity.high
                  : AnomalySeverity.medium,
              date: expenses[expenses.length - 1 - i].date,
            ),
          );
        }
      }
    });

    return anomalies..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Identify spending patterns and trends
  SpendingPattern analyzeSpendingPattern(List<LocalTransaction> transactions) {
    final hash = _hashTransactions(transactions);
    if (hash == _lastTransactionHash && _cachedPattern != null) {
      return _cachedPattern!;
    }

    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) {
      return SpendingPattern(
        trend: SpendingTrend.stable,
        avgDailySpending: 0,
        peakDay: 1,
        topCategory: TransactionCategory.otherExpense,
        consistencyScore: 0,
      );
    }

    // Calculate trend using linear regression
    final trend = _calculateTrend(expenses);

    // Find peak spending day
    final dayTotals = <int, double>{};
    for (var tx in expenses) {
      final day = tx.date.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + tx.amount;
    }
    final peakDay = dayTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find top category - handle nullable categories
    final categoryTotals = <TransactionCategory, double>{};
    for (var tx in expenses) {
      final category = tx.category ?? TransactionCategory.otherExpense;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + tx.amount;
    }
    final topCategory = categoryTotals.isEmpty
        ? TransactionCategory.otherExpense
        : categoryTotals.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

    // Calculate consistency score (0-100)
    final dailyAmounts = <double>[];
    final firstDate = expenses.first.date;
    final lastDate = expenses.last.date;
    final days = lastDate.difference(firstDate).inDays + 1;

    for (int i = 0; i < days; i++) {
      final date = firstDate.add(Duration(days: i));
      final dayTotal = expenses
          .where(
            (tx) =>
                tx.date.year == date.year &&
                tx.date.month == date.month &&
                tx.date.day == date.day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);
      dailyAmounts.add(dayTotal);
    }

    final avgDaily = dailyAmounts.reduce((a, b) => a + b) / dailyAmounts.length;
    final variance = _calculateVariance(dailyAmounts);
    final cv = variance == 0
        ? 0
        : sqrt(variance) / avgDaily; // Coefficient of variation
    final consistencyScore = max(0, min(100, 100 - (cv * 100)));

    _lastTransactionHash = hash;
    _cachedPattern = SpendingPattern(
      trend: trend,
      avgDailySpending: avgDaily,
      peakDay: peakDay,
      topCategory: topCategory,
      consistencyScore: consistencyScore.round(),
    );
    return _cachedPattern!;
  }

  /// Get personalized insights based on ML analysis
  List<MLInsight> generateInsights(List<LocalTransaction> transactions) {
    final hash = _hashTransactions(transactions);
    if (hash == _lastTransactionHash && _cachedInsights != null) {
      return _cachedInsights!;
    }

    final insights = <MLInsight>[];

    if (transactions.length < 10) {
      insights.add(
        MLInsight(
          title: 'Commencez à suivre',
          description:
              'Ajoutez plus de transactions pour obtenir des insights personnalisés',
          type: InsightType.info,
          priority: 1,
        ),
      );
      return insights;
    }

    // Anomaly insights
    final anomalies = detectAnomalies(transactions);
    if (anomalies.isNotEmpty) {
      final highSeverity = anomalies.where(
        (a) => a.severity == AnomalySeverity.high,
      );
      if (highSeverity.isNotEmpty) {
        insights.add(
          MLInsight(
            title: 'Dépense inhabituelle détectée',
            description:
                'Vous avez dépensé ${highSeverity.first.amount.toStringAsFixed(0)} FCFA en ${highSeverity.first.category.displayName}, ${((highSeverity.first.amount / highSeverity.first.expectedAmount - 1) * 100).toStringAsFixed(0)}% au-dessus de la moyenne',
            type: InsightType.warning,
            priority: 5,
          ),
        );
      }
    }

    // Pattern insights
    final pattern = analyzeSpendingPattern(transactions);

    if (pattern.consistencyScore > 70) {
      insights.add(
        MLInsight(
          title: 'Dépenses cohérentes',
          description:
              'Vos dépenses sont prévisibles (${pattern.consistencyScore}% de cohérence). Excellent pour la planification!',
          type: InsightType.positive,
          priority: 3,
        ),
      );
    } else if (pattern.consistencyScore < 40) {
      insights.add(
        MLInsight(
          title: 'Dépenses variables',
          description:
              'Vos dépenses varient beaucoup. Considérez un budget plus structuré.',
          type: InsightType.tip,
          priority: 4,
        ),
      );
    }

    // Trend insights
    if (pattern.trend == SpendingTrend.increasing) {
      insights.add(
        MLInsight(
          title: 'Tendance à la hausse',
          description:
              'Vos dépenses augmentent. Surveillez votre budget ce mois-ci.',
          type: InsightType.warning,
          priority: 4,
        ),
      );
    } else if (pattern.trend == SpendingTrend.decreasing) {
      insights.add(
        MLInsight(
          title: 'Excellente discipline',
          description: 'Vos dépenses diminuent. Continuez comme ça!',
          type: InsightType.positive,
          priority: 3,
        ),
      );
    }

    // Category insights
    final categoryTotals = <TransactionCategory, double>{};
    final expenses = transactions.where(
      (t) => t.type == TransactionType.expense,
    );
    for (var tx in expenses) {
      final category = tx.category ?? TransactionCategory.otherExpense;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + tx.amount;
    }
    final totalExpenses = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final topCategoryPercent =
        (categoryTotals[pattern.topCategory] ?? 0) / totalExpenses * 100;

    if (topCategoryPercent > 40) {
      insights.add(
        MLInsight(
          title: 'Concentration des dépenses',
          description:
              '${topCategoryPercent.toStringAsFixed(0)}% de vos dépenses sont en ${pattern.topCategory.displayName}. Diversifiez votre budget.',
          type: InsightType.tip,
          priority: 3,
        ),
      );
    }

    // Prediction insights
    final predictions = predictNextWeekSpending(transactions);
    if (predictions.isNotEmpty) {
      final avgPrediction =
          predictions.values.reduce((a, b) => a + b) / predictions.length;
      insights.add(
        MLInsight(
          title: 'Prévision semaine prochaine',
          description:
              'Dépense quotidienne prévue: ${avgPrediction.toStringAsFixed(0)} FCFA',
          type: InsightType.info,
          priority: 2,
        ),
      );
    }

    // Sort by priority (higher first)
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    _lastTransactionHash = hash;
    _cachedInsights = insights;
    return insights;
  }

  // Helper methods

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  SpendingTrend _calculateTrend(List<LocalTransaction> expenses) {
    if (expenses.length < 5) return SpendingTrend.stable;

    // Simple linear regression slope
    final n = expenses.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumX2 = 0.0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = expenses[i].amount;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final avgAmount = sumY / n;
    final relativeSlope = slope / avgAmount;

    if (relativeSlope > 0.05) return SpendingTrend.increasing;
    if (relativeSlope < -0.05) return SpendingTrend.decreasing;
    return SpendingTrend.stable;
  }

  /// Predict spending using lightweight data (for isolate)
  static Map<DateTime, double> predictNextWeekSpendingIsolate(
    List<TransactionData> transactions,
  ) {
    if (transactions.isEmpty) return {};

    final predictions = <DateTime, double>{};
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) return {};

    // Calculate daily averages for each day of week
    final dayOfWeekAverages = <int, List<double>>{};
    for (var tx in expenses) {
      final day = tx.date.weekday;
      dayOfWeekAverages.putIfAbsent(day, () => []).add(tx.amount);
    }

    // Calculate weighted moving average for each day
    final dayAverages = <int, double>{};
    dayOfWeekAverages.forEach((day, amounts) {
      amounts.sort();
      final recentWeight = amounts.length > 5 ? 0.6 : 0.5;
      final recent = amounts.sublist(max(0, amounts.length - 5));
      final older = amounts.length > 5
          ? amounts.sublist(0, amounts.length - 5)
          : <double>[];

      final recentAvg = recent.isEmpty
          ? 0.0
          : recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.isEmpty
          ? 0.0
          : older.reduce((a, b) => a + b) / older.length;

      dayAverages[day] =
          (recentAvg * recentWeight) + (olderAvg * (1 - recentWeight));
    });

    // Generate predictions for next 7 days
    final now = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      final dayOfWeek = date.weekday;
      final avgSpending = dayAverages[dayOfWeek] ?? 0.0;

      final variance = _calculateVarianceStatic(
        dayOfWeekAverages[dayOfWeek] ?? [],
      );
      final noise = (Random().nextDouble() - 0.5) * variance * 0.3;

      predictions[DateTime(date.year, date.month, date.day)] = max(
        0,
        avgSpending + noise,
      );
    }

    return predictions;
  }

  /// Analyze spending pattern using lightweight data (for isolate)
  static SpendingPattern analyzeSpendingPatternIsolate(
    List<TransactionData> transactions,
  ) {
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) {
      return SpendingPattern(
        trend: SpendingTrend.stable,
        avgDailySpending: 0,
        peakDay: 1,
        topCategory: TransactionCategory.otherExpense,
        consistencyScore: 0,
      );
    }

    // Calculate trend using linear regression
    final trend = _calculateTrendStatic(expenses);

    // Find peak spending day
    final dayTotals = <int, double>{};
    for (var tx in expenses) {
      final day = tx.date.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + tx.amount;
    }
    final peakDay = dayTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find top category
    final categoryTotals = <TransactionCategory, double>{};
    for (var tx in expenses) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    final topCategory = categoryTotals.isEmpty
        ? TransactionCategory.otherExpense
        : categoryTotals.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

    // Calculate consistency score (0-100)
    final dailyAmounts = <double>[];
    final firstDate = expenses.first.date;
    final lastDate = expenses.last.date;
    final days = lastDate.difference(firstDate).inDays + 1;

    for (int i = 0; i < days; i++) {
      final date = firstDate.add(Duration(days: i));
      final dayTotal = expenses
          .where(
            (tx) =>
                tx.date.year == date.year &&
                tx.date.month == date.month &&
                tx.date.day == date.day,
          )
          .fold(0.0, (sum, tx) => sum + tx.amount);
      dailyAmounts.add(dayTotal);
    }

    final avgDaily = dailyAmounts.reduce((a, b) => a + b) / dailyAmounts.length;
    final variance = _calculateVarianceStatic(dailyAmounts);
    final cv = variance == 0 ? 0 : sqrt(variance) / avgDaily;
    final consistencyScore = max(0, min(100, 100 - (cv * 100)));

    return SpendingPattern(
      trend: trend,
      avgDailySpending: avgDaily,
      peakDay: peakDay,
      topCategory: topCategory,
      consistencyScore: consistencyScore.round(),
    );
  }

  /// Generate insights using lightweight data (for isolate)
  static List<MLInsight> generateInsightsIsolate(
    List<TransactionData> transactions,
  ) {
    final insights = <MLInsight>[];

    if (transactions.length < 10) {
      insights.add(
        MLInsight(
          title: 'Commencez à suivre',
          description:
              'Ajoutez plus de transactions pour obtenir des insights personnalisés',
          type: InsightType.info,
          priority: 1,
        ),
      );
      return insights;
    }

    // Pattern insights
    final pattern = analyzeSpendingPatternIsolate(transactions);

    if (pattern.consistencyScore > 70) {
      insights.add(
        MLInsight(
          title: 'Dépenses cohérentes',
          description:
              'Vos dépenses sont prévisibles (${pattern.consistencyScore}% de cohérence). Excellent pour la planification!',
          type: InsightType.positive,
          priority: 3,
        ),
      );
    } else if (pattern.consistencyScore < 40) {
      insights.add(
        MLInsight(
          title: 'Dépenses variables',
          description:
              'Vos dépenses varient beaucoup. Considérez un budget plus structuré.',
          type: InsightType.tip,
          priority: 4,
        ),
      );
    }

    // Trend insights
    if (pattern.trend == SpendingTrend.increasing) {
      insights.add(
        MLInsight(
          title: 'Tendance à la hausse',
          description:
              'Vos dépenses augmentent. Surveillez votre budget ce mois-ci.',
          type: InsightType.warning,
          priority: 4,
        ),
      );
    } else if (pattern.trend == SpendingTrend.decreasing) {
      insights.add(
        MLInsight(
          title: 'Excellente discipline',
          description: 'Vos dépenses diminuent. Continuez comme ça!',
          type: InsightType.positive,
          priority: 3,
        ),
      );
    }

    // Category insights
    final categoryTotals = <TransactionCategory, double>{};
    final expenses = transactions.where(
      (t) => t.type == TransactionType.expense,
    );
    for (var tx in expenses) {
      categoryTotals[tx.category] =
          (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    final totalExpenses = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final topCategoryPercent =
        (categoryTotals[pattern.topCategory] ?? 0) / totalExpenses * 100;

    if (topCategoryPercent > 40) {
      insights.add(
        MLInsight(
          title: 'Concentration des dépenses',
          description:
              '${topCategoryPercent.toStringAsFixed(0)}% de vos dépenses sont en ${pattern.topCategory.displayName}. Diversifiez votre budget.',
          type: InsightType.tip,
          priority: 3,
        ),
      );
    }

    // Prediction insights
    final predictions = predictNextWeekSpendingIsolate(transactions);
    if (predictions.isNotEmpty) {
      final avgPrediction =
          predictions.values.reduce((a, b) => a + b) / predictions.length;
      insights.add(
        MLInsight(
          title: 'Prévision semaine prochaine',
          description:
              'Dépense quotidienne prévue: ${avgPrediction.toStringAsFixed(0)} FCFA',
          type: InsightType.info,
          priority: 2,
        ),
      );
    }

    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights;
  }

  // Static helper methods for isolate

  static double _calculateVarianceStatic(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  static SpendingTrend _calculateTrendStatic(List<TransactionData> expenses) {
    if (expenses.length < 5) return SpendingTrend.stable;

    final n = expenses.length;
    var sumX = 0.0;
    var sumY = 0.0;
    var sumXY = 0.0;
    var sumX2 = 0.0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = expenses[i].amount;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final avgAmount = sumY / n;
    final relativeSlope = slope / avgAmount;

    if (relativeSlope > 0.05) return SpendingTrend.increasing;
    if (relativeSlope < -0.05) return SpendingTrend.decreasing;
    return SpendingTrend.stable;
  }
}

// Data models for ML insights

class SpendingAnomaly {
  final TransactionCategory category;
  final double amount;
  final double expectedAmount;
  final AnomalySeverity severity;
  final DateTime date;

  SpendingAnomaly({
    required this.category,
    required this.amount,
    required this.expectedAmount,
    required this.severity,
    required this.date,
  });
}

enum AnomalySeverity { low, medium, high }

class SpendingPattern {
  final SpendingTrend trend;
  final double avgDailySpending;
  final int peakDay; // 1-7 (Monday-Sunday)
  final TransactionCategory topCategory;
  final int consistencyScore; // 0-100

  SpendingPattern({
    required this.trend,
    required this.avgDailySpending,
    required this.peakDay,
    required this.topCategory,
    required this.consistencyScore,
  });
}

enum SpendingTrend { increasing, stable, decreasing }

class MLInsight {
  final String title;
  final String description;
  final InsightType type;
  final int priority; // 1-5, higher is more important

  MLInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });
}

enum InsightType { positive, warning, tip, info }
