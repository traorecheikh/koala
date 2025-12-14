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

    // 2. New Mega Persona Metrics
    final weekendRatio = _calculateWeekendRatio(transactions);
    final nightRatio = _calculateNightRatio(transactions);
    final avgAmount = _calculateAverageAmount(transactions);
    final categoryPreferences = _calculateCategoryPreferences(transactions);
    final dominantCategory = categoryPreferences.isNotEmpty
        ? categoryPreferences.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : 'Autre';

    // 3. Category preferences (already calculated above)

    // 4. Determine Persona Type (Now just passing the raw profile to be classified by definitions later)
    // For backward compatibility, we still assign a basic type here, but the UI will use the smart definitions.
    // We can also run the full classification here if we want to store the "Mega Persona" name directly.

    // For now, let's store a basic one, but populating all the rich data fields is key.

    return UserFinancialProfile(
      personaType: FinancialPersona.planner
          .name, // Placeholder, real classification happens in UI/Service based on data
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

  double _calculateConsistency(List<LocalTransaction> txs) {
    return 0.5; // Placeholder
  }

  double _calculateDiscretionaryRatio(List<LocalTransaction> txs) {
    return 0.4; // Placeholder
  }

  double _calculateFrequency(List<LocalTransaction> txs) {
    if (txs.isEmpty) return 0.0;
    final duration = txs.last.date.difference(txs.first.date).inDays.abs() + 1;
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
    return [];
  }

  List<String> getAdviceForPersona(String personaName) {
    final persona = FinancialPersona.values.firstWhere(
        (e) => e.name == personaName,
        orElse: () => FinancialPersona.planner);
    return getAdvice(persona);
  }
}

