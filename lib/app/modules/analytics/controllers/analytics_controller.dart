import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/ml_service.dart';

class AnalyticsController extends GetxController {
  final transactions = <LocalTransaction>[].obs;
  final selectedPeriod = 'Semaine'.obs; // Semaine, Mois, Année
  final mlService = MLService();
  final mlInsights = <MLInsight>[].obs;
  final spendingPattern = Rx<SpendingPattern?>(null);
  final predictions = <DateTime, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    transactions.assignAll(transactionBox.values.toList());
    transactionBox.watch().listen((_) {
      transactions.assignAll(transactionBox.values.toList());
      _runMLAnalysis();
    });
    _runMLAnalysis();
  }

  void _runMLAnalysis() {
    if (transactions.isEmpty) return;

    // Generate ML insights
    mlInsights.value = mlService.generateInsights(transactions);

    // Analyze spending pattern
    spendingPattern.value = mlService.analyzeSpendingPattern(transactions);

    // Get predictions
    predictions.value = mlService.predictNextWeekSpending(transactions);
  }

  List<LocalTransaction> get filteredTransactions {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod.value) {
      case 'Semaine':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Mois':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Année':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    return transactions.where((t) => t.date.isAfter(startDate)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Map<String, double> get spendingByCategory {
    final categories = <String, double>{};
    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.expense) {
        final category =
            transaction.category ?? TransactionCategory.otherExpense;
        final categoryName = category.displayName;
        categories.update(
          categoryName,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }
    return categories;
  }

  double get totalIncome {
    return filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => totalIncome - totalExpenses;

  double get savingsRate {
    if (totalIncome == 0) return 0.0;
    return ((totalIncome - totalExpenses) / totalIncome) * 100;
  }

  double get averageDailySpending {
    if (filteredTransactions.isEmpty) return 0.0;
    final expenses = filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    if (expenses.isEmpty) return 0.0;

    final firstDate = expenses.first.date;
    final days = DateTime.now().difference(firstDate).inDays + 1;
    return totalExpenses / days;
  }

  double get predictedBalance {
    final today = DateTime.now();
    final endOfMonth = DateTime(today.year, today.month + 1, 0);
    final remainingDays = endOfMonth.difference(today).inDays;
    final currentBalance = transactions
        .map((t) => t.type == TransactionType.income ? t.amount : -t.amount)
        .fold(0.0, (a, b) => a + b);
    return currentBalance - (averageDailySpending * remainingDays);
  }

  // Get spending trend data for line chart (last 7 days)
  Map<DateTime, double> get dailySpendingTrend {
    final trend = <DateTime, double>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      trend[date] = 0.0;
    }

    for (var transaction in filteredTransactions) {
      if (transaction.type == TransactionType.expense) {
        final dateKey = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );
        if (trend.containsKey(dateKey)) {
          trend[dateKey] = trend[dateKey]! + transaction.amount;
        }
      }
    }

    return trend;
  }

  // Get top 5 spending categories
  List<MapEntry<String, double>> get topSpendingCategories {
    final sorted = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  // Calculate comparison with previous period
  double get percentageChange {
    final now = DateTime.now();
    DateTime currentStart, previousStart, previousEnd;

    switch (selectedPeriod.value) {
      case 'Semaine':
        currentStart = now.subtract(const Duration(days: 7));
        previousStart = now.subtract(const Duration(days: 14));
        previousEnd = currentStart;
        break;
      case 'Mois':
        currentStart = DateTime(now.year, now.month, 1);
        previousStart = DateTime(now.year, now.month - 1, 1);
        previousEnd = DateTime(now.year, now.month, 0);
        break;
      case 'Année':
        currentStart = DateTime(now.year, 1, 1);
        previousStart = DateTime(now.year - 1, 1, 1);
        previousEnd = DateTime(now.year - 1, 12, 31);
        break;
      default:
        return 0.0;
    }

    final previousExpenses = transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(previousStart) &&
              t.date.isBefore(previousEnd),
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    if (previousExpenses == 0) return 0.0;
    return ((totalExpenses - previousExpenses) / previousExpenses) * 100;
  }
}
