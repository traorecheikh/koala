import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/ml/financial_intelligence.dart';
import 'dart:math';

class PredictiveSpendingService {
  /// Analyzes spending and returns a list of alerts for categories at risk.
  List<SpendingAlert> analyzeSpending({
    required List<LocalTransaction> transactions,
    required List<Budget> budgets,
  }) {
    // 1. Setup
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dayOfMonth = now.day;

    // Safety check for dayOfMonth to avoid division by zero (shouldn't happen 1-31)
    final safeDayOfMonth = max(1, dayOfMonth);
    final remainingDays = daysInMonth - safeDayOfMonth;

    final alerts = <SpendingAlert>[];

    // 2. Filter transactions for this month and expenses only
    final thisMonthTransactions = transactions
        .where((t) =>
            t.type == TransactionType.expense && !t.date.isBefore(monthStart))
        .toList();

    // 3. Analyze each budget
    for (final budget in budgets) {
      if (budget.amount <= 0) continue;

      // Get spending for this category
      final categorySpending = thisMonthTransactions
          .where((t) => t.categoryId == budget.categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Current Velocity (Average daily spend so far)
      final avgDailySpend = categorySpending / safeDayOfMonth;

      // Projected Total (Spent so far + (Average * Remaining Days))
      // We use linear projection.
      final projectedTotal = categorySpending + (avgDailySpend * remainingDays);

      // Check if projection exceeds budget
      if (projectedTotal > budget.amount) {
        // Calculate overage percentage
        final overageRatio = projectedTotal / budget.amount;

        AlertSeverity severity = AlertSeverity.low;
        String message = '';

        if (categorySpending > budget.amount) {
          // Already exceeded
          severity = AlertSeverity.critical;
          message = 'Budget dépassé !';
        } else if (overageRatio > 1.20) {
          // Projected to exceed by > 20%
          severity = AlertSeverity.high;
          message = 'Risque critique de dépassement.';
        } else if (overageRatio > 1.05) {
          // Projected to exceed by > 5%
          severity = AlertSeverity.medium;
          message = 'Attention, vous consommez trop vite.';
        } else {
          // Projected to slightly exceed or just hit limit (ignore noise)
          if (overageRatio > 1.0) {
            severity = AlertSeverity.low;
            message = 'Trajectoire légèrement au-dessus.';
          } else {
            continue; // No alert
          }
        }

        alerts.add(SpendingAlert(
          categoryId: budget.categoryId,
          message: message,
          severity: severity,
          projectedAmount: projectedTotal,
          budgetAmount: budget.amount,
          currentAmount: categorySpending,
        ));
      }
    }

    // Sort by severity (Critical first)
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return alerts;
  }
}
