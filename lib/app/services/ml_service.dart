import 'dart:math';

import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';

/// Lightweight DTO for isolate communication
class TransactionData {
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryName;

  TransactionData({
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryName,
  });

  factory TransactionData.fromTransaction(LocalTransaction tx) {
    String name = 'Autre';
    try {
      final controller = Get.find<CategoriesController>();
      if (tx.categoryId != null) {
        final cat = controller.categories.firstWhereOrNull((c) => c.id == tx.categoryId);
        if (cat != null) name = cat.name;
      } else if (tx.category != null) {
        name = tx.category!.displayName;
      }
    } catch (e) {
      // Fallback if controller not found or error
      if (tx.category != null) name = tx.category!.displayName;
    }

    return TransactionData(
      amount: tx.amount,
      date: tx.date,
      type: tx.type,
      categoryName: name,
    );
  }
}

class MLService {
  String? _lastTransactionHash;
  List<MLInsight>? _cachedInsights;
  SpendingPattern? _cachedPattern;
  Map<DateTime, double>? _cachedPredictions;

  String _hashTransactions(List<LocalTransaction> transactions) {
    if (transactions.isEmpty) return 'empty';
    final first = transactions.first;
    final last = transactions.last;
    return '${transactions.length}_${first.date.millisecondsSinceEpoch}_${last.date.millisecondsSinceEpoch}_${first.amount}_${last.amount}';
  }

  // --- Helper to get name ---
  String _getCategoryName(LocalTransaction tx) {
    try {
      final controller = Get.find<CategoriesController>();
      if (tx.categoryId != null) {
        final cat = controller.categories.firstWhereOrNull((c) => c.id == tx.categoryId);
        if (cat != null) return cat.name;
      }
      return tx.category?.displayName ?? 'Autre';
    } catch (_) {
      return tx.category?.displayName ?? 'Autre';
    }
  }

  Map<DateTime, double> predictNextWeekSpending(List<LocalTransaction> transactions) {
    final hash = _hashTransactions(transactions);
    if (hash == _lastTransactionHash && _cachedPredictions != null) {
      return _cachedPredictions!;
    }

    if (transactions.isEmpty) return {};

    final predictions = <DateTime, double>{};
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) return {};

    final dayOfWeekAverages = <int, List<double>>{};
    for (var tx in expenses) {
      final day = tx.date.weekday;
      dayOfWeekAverages.putIfAbsent(day, () => []).add(tx.amount);
    }

    final dayAverages = <int, double>{};
    dayOfWeekAverages.forEach((day, amounts) {
      amounts.sort();
      final recentWeight = amounts.length > 5 ? 0.6 : 0.5;
      final recent = amounts.sublist(max(0, amounts.length - 5));
      final older = amounts.length > 5 ? amounts.sublist(0, amounts.length - 5) : <double>[];

      final recentAvg = recent.isEmpty ? 0.0 : recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.isEmpty ? 0.0 : older.reduce((a, b) => a + b) / older.length;

      dayAverages[day] = (recentAvg * recentWeight) + (olderAvg * (1 - recentWeight));
    });

    final now = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      final dayOfWeek = date.weekday;
      final avgSpending = dayAverages[dayOfWeek] ?? 0.0;
      final variance = _calculateVariance(dayOfWeekAverages[dayOfWeek] ?? []);
      final noise = (Random().nextDouble() - 0.5) * variance * 0.3;

      predictions[DateTime(date.year, date.month, date.day)] = max(0, avgSpending + noise);
    }

    _lastTransactionHash = hash;
    _cachedPredictions = predictions;
    return predictions;
  }

  List<SpendingAnomaly> detectAnomalies(List<LocalTransaction> transactions) {
    final anomalies = <SpendingAnomaly>[];
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenses.length < 10) return anomalies;

    final categoryGroups = <String, List<double>>{};
    for (var tx in expenses) {
      final name = _getCategoryName(tx);
      categoryGroups.putIfAbsent(name, () => []).add(tx.amount);
    }

    categoryGroups.forEach((categoryName, amounts) {
      if (amounts.length < 5) return;

      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = _calculateVariance(amounts);
      final stdDev = sqrt(variance);

      for (int i = 0; i < min(5, amounts.length); i++) {
        final amount = amounts[amounts.length - 1 - i];
        final zScore = stdDev == 0 ? 0 : (amount - mean) / stdDev;

        if (zScore.abs() > 2.0) {
          anomalies.add(
            SpendingAnomaly(
              categoryName: categoryName,
              amount: amount,
              expectedAmount: mean,
              severity: zScore.abs() > 3.0 ? AnomalySeverity.high : AnomalySeverity.medium,
              date: expenses[expenses.length - 1 - i].date,
            ),
          );
        }
      }
    });

    return anomalies..sort((a, b) => b.date.compareTo(a.date));
  }

  SpendingPattern analyzeSpendingPattern(List<LocalTransaction> transactions) {
    final hash = _hashTransactions(transactions);
    if (hash == _lastTransactionHash && _cachedPattern != null) {
      return _cachedPattern!;
    }

    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (expenses.isEmpty) {
      return SpendingPattern(
        trend: SpendingTrend.stable,
        avgDailySpending: 0,
        peakDay: 1,
        topCategory: 'Aucune',
        consistencyScore: 0,
      );
    }

    final trend = _calculateTrend(expenses);

    final dayTotals = <int, double>{};
    for (var tx in expenses) {
      final day = tx.date.weekday;
      dayTotals[day] = (dayTotals[day] ?? 0) + tx.amount;
    }
    final peakDay = dayTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final categoryTotals = <String, double>{};
    for (var tx in expenses) {
      final name = _getCategoryName(tx);
      categoryTotals[name] = (categoryTotals[name] ?? 0) + tx.amount;
    }
    final topCategory = categoryTotals.isEmpty
        ? 'Aucune'
        : categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final dailyAmounts = <double>[];
    final firstDate = expenses.first.date;
    final lastDate = expenses.last.date;
    final days = lastDate.difference(firstDate).inDays + 1;

    for (int i = 0; i < days; i++) {
      final date = firstDate.add(Duration(days: i));
      final dayTotal = expenses
          .where((tx) => tx.date.year == date.year && tx.date.month == date.month && tx.date.day == date.day)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      dailyAmounts.add(dayTotal);
    }

    final avgDaily = dailyAmounts.reduce((a, b) => a + b) / dailyAmounts.length;
    final variance = _calculateVariance(dailyAmounts);
    final cv = variance == 0 ? 0 : sqrt(variance) / avgDaily;
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

  List<MLInsight> generateInsights(List<LocalTransaction> transactions) {
    final hash = _hashTransactions(transactions);
    if (hash == _lastTransactionHash && _cachedInsights != null) {
      return _cachedInsights!;
    }

    final insights = <MLInsight>[];

    if (transactions.length < 1) {
      insights.add(
        MLInsight(
          title: 'Commencez à suivre',
          description: 'Ajoutez plus de transactions pour obtenir des insights personnalisés',
          type: InsightType.info,
          priority: 1,
        ),
      );
      return insights;
    }

    final anomalies = detectAnomalies(transactions);
    if (anomalies.isNotEmpty) {
      final highSeverity = anomalies.where((a) => a.severity == AnomalySeverity.high);
      if (highSeverity.isNotEmpty) {
        insights.add(
          MLInsight(
            title: 'Dépense inhabituelle',
            description: 'Dépense de ${highSeverity.first.amount.toStringAsFixed(0)} FCFA en ${highSeverity.first.categoryName}, bien au-dessus de votre moyenne.',
            type: InsightType.warning,
            priority: 5,
          ),
        );
      }
    }

    final pattern = analyzeSpendingPattern(transactions);

    if (pattern.consistencyScore > 70) {
      insights.add(
        MLInsight(
          title: 'Dépenses stables',
          description: 'Vos dépenses sont très cohérentes (${pattern.consistencyScore}%). C\'est excellent pour gérer un budget !',
          type: InsightType.positive,
          priority: 3,
        ),
      );
    }

    if (pattern.trend == SpendingTrend.increasing) {
      insights.add(
        MLInsight(
          title: 'Attention aux dépenses',
          description: 'Vos dépenses sont en hausse récente. Essayez de réduire les achats non essentiels.',
          type: InsightType.warning,
          priority: 4,
        ),
      );
    } else if (pattern.trend == SpendingTrend.decreasing) {
      insights.add(
        MLInsight(
          title: 'Bonne discipline',
          description: 'Vos dépenses diminuent. Vous êtes sur la bonne voie pour économiser !',
          type: InsightType.positive,
          priority: 3,
        ),
      );
    }

    // Category concentration
    final categoryTotals = <String, double>{};
    final expenses = transactions.where((t) => t.type == TransactionType.expense);
    for (var tx in expenses) {
      final name = _getCategoryName(tx);
      categoryTotals[name] = (categoryTotals[name] ?? 0) + tx.amount;
    }
    final totalExpenses = categoryTotals.values.fold(0.0, (a, b) => a + b);
    
    if (totalExpenses > 0) {
        final topCategoryPercent = (categoryTotals[pattern.topCategory] ?? 0) / totalExpenses * 100;
        if (topCategoryPercent > 40) {
          insights.add(
            MLInsight(
              title: 'Gros poste de dépense',
              description: '${topCategoryPercent.toStringAsFixed(0)}% de vos dépenses vont dans "${pattern.topCategory}". Pouvez-vous optimiser ce poste ?',
              type: InsightType.tip,
              priority: 3,
            ),
          );
        }
    }

    final predictions = predictNextWeekSpending(transactions);
    if (predictions.isNotEmpty) {
      final avgPrediction = predictions.values.reduce((a, b) => a + b) / predictions.length;
      insights.add(
        MLInsight(
          title: 'Prévision',
          description: 'Basé sur vos habitudes, vous dépenserez environ ${avgPrediction.toStringAsFixed(0)} FCFA par jour la semaine prochaine.',
          type: InsightType.info,
          priority: 2,
        ),
      );
    }

    insights.sort((a, b) => b.priority.compareTo(a.priority));
    _lastTransactionHash = hash;
    _cachedInsights = insights;
    return insights;
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  SpendingTrend _calculateTrend(List<LocalTransaction> expenses) {
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

class SpendingAnomaly {
  final String categoryName;
  final double amount;
  final double expectedAmount;
  final AnomalySeverity severity;
  final DateTime date;

  SpendingAnomaly({
    required this.categoryName,
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
  final int peakDay;
  final String topCategory;
  final int consistencyScore;

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
  final int priority;

  MLInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });
}

enum InsightType { positive, warning, tip, info }