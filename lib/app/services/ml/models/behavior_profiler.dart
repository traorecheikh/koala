import 'dart:math';

import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:ml_linalg/distance.dart';
import 'package:ml_linalg/vector.dart';

enum FinancialPersona {
  saver,
  spender,
  planner,
  survival,
  fluctuator,
}

class BehaviorProfiler {
  // Centroids for each persona (normalized 0-1)
  // [SavingsRate, Consistency, DiscretionaryRatio, Frequency]
  static final Map<FinancialPersona, Vector> _centroids = {
    FinancialPersona.saver: Vector.fromList([0.8, 0.7, 0.2, 0.4]),
    FinancialPersona.spender: Vector.fromList([0.1, 0.4, 0.8, 0.7]),
    FinancialPersona.planner: Vector.fromList([0.5, 0.9, 0.4, 0.5]),
    FinancialPersona.survival: Vector.fromList([0.05, 0.8, 0.1, 0.3]),
    FinancialPersona.fluctuator: Vector.fromList([0.3, 0.2, 0.6, 0.9]),
  };

  // Essential categories that are NOT discretionary spending
  static const Set<String> _essentialCategories = {
    'Loyer',
    'Factures',
    'Services',
    'Courses',
    'Santé',
    'Éducation',
    'Transport',
    'Assurance',
  };

  UserFinancialProfile createProfile(List<LocalTransaction> transactions) {
    if (transactions.isEmpty) {
      return UserFinancialProfile(
        personaType: FinancialPersona.planner.name, // Default
        savingsRate: 0,
        consistencyScore: 0,
        categoryPreferences: {},
        detectedPatterns: [],
      );
    }

    // 1. Calculate features
    final savingsRate = _calculateSavingsRate(transactions);
    final consistency = _calculateConsistency(transactions);
    final discretionaryRatio = _calculateDiscretionaryRatio(transactions);
    final frequency = _calculateFrequency(transactions);

    // 2. Classify persona using ML (centroid-based classification)
    final persona = _classifyPersona(
        savingsRate, consistency, discretionaryRatio, frequency);

    // 3. Calculate additional metrics
    final weekendRatio = _calculateWeekendRatio(transactions);
    final nightRatio = _calculateNightRatio(transactions);
    final avgAmount = _calculateAverageAmount(transactions);
    final categoryPreferences = _calculateCategoryPreferences(transactions);
    final dominantCategory = categoryPreferences.isNotEmpty
        ? categoryPreferences.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'Autre';

    return UserFinancialProfile(
      personaType: persona.name, // Now uses REAL ML classification
      savingsRate: savingsRate,
      consistencyScore: consistency,
      categoryPreferences: categoryPreferences,
      detectedPatterns: [],
      weekendRatio: weekendRatio,
      nightRatio: nightRatio,
      dominantCategory: dominantCategory,
      averageAmount: avgAmount,
    );
  }

  /// Classify user persona using Euclidean distance to predefined centroids
  /// This is a K-nearest-neighbor style classification with K=1
  FinancialPersona _classifyPersona(
    double savingsRate,
    double consistency,
    double discretionaryRatio,
    double frequency,
  ) {
    // Create user feature vector (normalized 0-1)
    final userVector = Vector.fromList([
      savingsRate.clamp(0.0, 1.0),
      consistency.clamp(0.0, 1.0),
      discretionaryRatio.clamp(0.0, 1.0),
      frequency.clamp(0.0, 1.0),
    ]);

    // Find nearest centroid using Euclidean distance
    double minDistance = double.infinity;
    FinancialPersona closestPersona = FinancialPersona.planner;

    for (final entry in _centroids.entries) {
      final distance =
          userVector.distanceTo(entry.value, distance: Distance.euclidean);
      if (distance < minDistance) {
        minDistance = distance;
        closestPersona = entry.key;
      }
    }

    return closestPersona;
  }

  double _calculateSavingsRate(List<LocalTransaction> txs) {
    double income = 0;
    double expense = 0;
    for (var tx in txs) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    if (income == 0) return 0.0;
    return max(0.0, (income - expense) / income);
  }

  /// Calculate spending consistency using coefficient of variation
  /// Groups transactions by week, calculates variance of weekly spending
  /// High consistency = low variance = predictable spending patterns
  double _calculateConsistency(List<LocalTransaction> txs) {
    // Filter for expenses only
    final expenses =
        txs.where((tx) => tx.type == TransactionType.expense).toList();
    if (expenses.length < 7) return 0.5; // Not enough data, return neutral

    // Sort by date
    expenses.sort((a, b) => a.date.compareTo(b.date));

    // Group by week number
    final Map<int, double> weeklySpending = {};
    for (final tx in expenses) {
      // Week number = days since first transaction / 7
      final weekNum = tx.date.difference(expenses.first.date).inDays ~/ 7;
      weeklySpending[weekNum] = (weeklySpending[weekNum] ?? 0) + tx.amount;
    }

    if (weeklySpending.isEmpty || weeklySpending.length < 2) return 0.5;

    // Calculate mean
    final values = weeklySpending.values.toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    if (mean == 0) return 0.5;

    // Calculate variance
    double variance = 0;
    for (final v in values) {
      variance += pow(v - mean, 2);
    }
    variance /= values.length;

    // Coefficient of Variation (CV) = stddev / mean
    final cv = sqrt(variance) / mean;

    // Normalize: CV of 0 = consistency 1.0, CV of 1+ = consistency 0.0
    // Lower CV means more consistent spending
    return max(0.0, min(1.0, 1.0 - cv));
  }

  /// Calculate ratio of discretionary spending to total spending
  /// Discretionary = non-essential categories (entertainment, shopping, etc.)
  double _calculateDiscretionaryRatio(List<LocalTransaction> txs) {
    double totalSpending = 0;
    double discretionarySpending = 0;

    for (final tx in txs) {
      if (tx.type != TransactionType.expense) continue;

      final categoryName = tx.category?.displayName ?? 'Autre';
      totalSpending += tx.amount;

      // If NOT in essential categories, it's discretionary
      if (!_essentialCategories.contains(categoryName)) {
        discretionarySpending += tx.amount;
      }
    }

    if (totalSpending == 0) return 0.0;
    return discretionarySpending / totalSpending;
  }

  double _calculateFrequency(List<LocalTransaction> txs) {
    if (txs.isEmpty) return 0.0;
    final sorted = List<LocalTransaction>.from(txs)
      ..sort((a, b) => a.date.compareTo(b.date));
    final duration =
        sorted.last.date.difference(sorted.first.date).inDays.abs() + 1;
    final perDay = txs.length / duration;
    return min(1.0, perDay / 5.0);
  }

  double _calculateWeekendRatio(List<LocalTransaction> txs) {
    if (txs.isEmpty) return 0.0;
    int weekendCount = 0;
    for (var tx in txs) {
      if (tx.date.weekday >= 6) weekendCount++;
    }
    return weekendCount / txs.length;
  }

  double _calculateNightRatio(List<LocalTransaction> txs) {
    if (txs.isEmpty) return 0.0;
    int nightCount = 0;
    for (var tx in txs) {
      if (tx.date.hour >= 20 || tx.date.hour <= 5) nightCount++;
    }
    return nightCount / txs.length;
  }

  double _calculateAverageAmount(List<LocalTransaction> txs) {
    if (txs.isEmpty) return 0.0;
    double total = 0;
    int count = 0;
    for (var tx in txs) {
      if (tx.type == TransactionType.expense) {
        total += tx.amount;
        count++;
      }
    }
    return count == 0 ? 0.0 : total / count;
  }

  Map<String, double> _calculateCategoryPreferences(
      List<LocalTransaction> txs) {
    final totals = <String, double>{};
    double grandTotal = 0;

    for (var tx in txs) {
      if (tx.type == TransactionType.expense) {
        final cat = tx.category?.displayName ?? 'Autre';
        totals[cat] = (totals[cat] ?? 0) + tx.amount;
        grandTotal += tx.amount;
      }
    }

    if (grandTotal == 0) return {};

    return totals.map((key, value) => MapEntry(key, value / grandTotal));
  }

  List<String> getAdvice(FinancialPersona persona) {
    // Can be localized later
    switch (persona) {
      case FinancialPersona.saver:
        return [
          'Vous épargnez bien ! Pensez à diversifier vos investissements.'
        ];
      case FinancialPersona.spender:
        return ['Essayez la règle des 50/30/20 pour mieux gérer vos envies.'];
      case FinancialPersona.planner:
        return [
          'Votre budget est solide. Avez-vous un fonds d\'urgence de 6 mois ?'
        ];
      case FinancialPersona.survival:
        return [
          'Priorité : constituez un petit fonds de secours de 50.000 FCFA.'
        ];
      case FinancialPersona.fluctuator:
        return ['Lissez vos dépenses en mettant de côté les mois fastes.'];
    }
  }

  List<String> getAdviceForPersona(String personaName) {
    final persona = FinancialPersona.values.firstWhere(
        (e) => e.name == personaName,
        orElse: () => FinancialPersona.planner);
    return getAdvice(persona);
  }
}
