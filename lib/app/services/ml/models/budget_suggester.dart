import 'package:koaa/app/data/models/local_transaction.dart';

class BudgetSuggester {
  double suggestBudgetForCategory(String categoryId, List<LocalTransaction> history, {int months = 3}) {
    final now = DateTime.now();
    final cutoffDate = DateTime(now.year, now.month - (months -1), 1); // Start of X months ago

    final relevantTransactions = history.where((t) =>
        t.type == TransactionType.expense && // Assuming budgets are for expenses
        t.categoryId == categoryId &&
        t.date.isAfter(cutoffDate)
    ).toList();

    if (relevantTransactions.isEmpty) {
      return 0; // No historical data for this category
    }

    // Group by month and sum expenses
    final monthlyExpenses = <String, double>{};
    for (var tx in relevantTransactions) {
      final monthKey = '${tx.date.year}-${tx.date.month}';
      monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0) + tx.amount;
    }

    if (monthlyExpenses.isEmpty) return 0;

    // Calculate average monthly spending
    final averageMonthlySpending = monthlyExpenses.values.reduce((a, b) => a + b) / monthlyExpenses.length;

    // Suggest budget: average + a small buffer (e.g., 10%)
    return (averageMonthlySpending * 1.1).roundToDouble();
  }
}
