import 'package:koaa/app/data/models/local_transaction.dart';
import 'dart:math';

class BudgetSuggester {
  /// Suggests a budget based on the 80th percentile of historical monthly spending
  /// This ensures the budget covers "most" months without being skewed by a single massive purchase
  double suggestBudgetForCategory(
      String categoryId, List<LocalTransaction> history,
      {int months = 6}) {
    final now = DateTime.now();
    final cutoffDate =
        DateTime(now.year, now.month - months, 1); // Look back N months

    final relevantTransactions = history
        .where((t) =>
            t.type == TransactionType.expense &&
            t.type == TransactionType.expense &&
            t.categoryId == categoryId &&
            t.date.isAfter(cutoffDate) &&
            (t.linkedDebtId == null || t.linkedDebtId!.isEmpty))
        .toList();

    if (relevantTransactions.isEmpty) {
      return 0; // No historical data
    }

    // 1. Group by Month (Key: "2023-5")
    final monthlyTotals = <String, double>{};
    for (var tx in relevantTransactions) {
      final key = '${tx.date.year}-${tx.date.month}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + tx.amount;
    }

    if (monthlyTotals.isEmpty) return 0;

    final totals = monthlyTotals.values.toList();
    totals.sort(); // Ascending

    // 2. Calculate P80 (80th Percentile)
    // If we have [100, 110, 120, 500], Average is 207 (too high), Median is 115. P80 is decent buffer.

    double suggestedAmount;

    if (totals.length < 3) {
      // Not enough sample size for percentiles, use Average + 10% buffer
      final avg = totals.reduce((a, b) => a + b) / totals.length;
      suggestedAmount = avg * 1.1;
    } else {
      // Index for 80th percentile
      final index = (totals.length * 0.8).ceil() - 1;
      // Clamp index safe
      final safeIndex = max(0, min(index, totals.length - 1));
      suggestedAmount = totals[safeIndex];
    }

    // Round to nearest 500 for cleanliness
    return _roundToNiceNumber(suggestedAmount);
  }

  double _roundToNiceNumber(double val) {
    if (val < 1000) return (val / 100).ceil() * 100;
    return (val / 500).ceil() * 500;
  }
}
