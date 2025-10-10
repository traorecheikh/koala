import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/ml_service.dart';

class AnalyticsController extends GetxController {
  final transactions = <LocalTransaction>[].obs;
  final selectedPeriod = 'Semaine'.obs;
  final mlService = MLService();
  final mlInsights = <MLInsight>[].obs;
  final spendingPattern = Rx<SpendingPattern?>(null);
  final predictions = <DateTime, double>{}.obs;
  final isAnalyzing = false.obs;

  // Cached computed values
  final _filteredTransactions = <LocalTransaction>[].obs;
  final _spendingByCategory = <String, double>{}.obs;
  final _totalIncome = 0.0.obs;
  final _totalExpenses = 0.0.obs;
  final _dailySpendingTrend = <DateTime, double>{}.obs;
  final _topSpendingCategories = <MapEntry<String, double>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    transactions.assignAll(transactionBox.values.toList());

    // Debounce transaction updates to avoid excessive recalculations
    transactionBox.watch().listen((_) {
      transactions.assignAll(transactionBox.values.toList());
      _scheduleUpdate();
    });

    // Listen to period changes
    ever(selectedPeriod, (_) => _updateCachedData());

    _updateCachedData();
    _runMLAnalysisAsync();
  }

  // Debounce updates to avoid excessive recalculations
  void _scheduleUpdate() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _updateCachedData();
      _runMLAnalysisAsync();
    });
  }

  // Update all cached data at once
  void _updateCachedData() {
    _updateFilteredTransactions();
    _updateSpendingByCategory();
    _updateTotals();
    _updateDailySpendingTrend();
    _updateTopSpendingCategories();
  }

  void _updateFilteredTransactions() {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod.value) {
      case 'Semaine':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Mois':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Anne':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    _filteredTransactions.value =
        transactions.where((t) => t.date.isAfter(startDate)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _updateSpendingByCategory() {
    final categories = <String, double>{};
    for (var transaction in _filteredTransactions) {
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
    _spendingByCategory.value = categories;
  }

  void _updateTotals() {
    _totalIncome.value = _filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    _totalExpenses.value = _filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _updateDailySpendingTrend() {
    final trend = <DateTime, double>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      trend[date] = 0.0;
    }

    for (var transaction in _filteredTransactions) {
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

    _dailySpendingTrend.value = trend;
  }

  void _updateTopSpendingCategories() {
    final sorted = _spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _topSpendingCategories.value = sorted.take(5).toList();
  }

  // Run ML analysis asynchronously to avoid blocking UI
  Future<void> _runMLAnalysisAsync() async {
    if (transactions.isEmpty || isAnalyzing.value) return;

    isAnalyzing.value = true;

    try {
      // Convert to lightweight DTOs that can be sent to isolates
      final transactionDataList = transactions
          .map((tx) => TransactionData.fromTransaction(tx))
          .toList();

      // Run heavy ML computations in isolate/compute
      final results = await compute(_performMLAnalysis, transactionDataList);

      mlInsights.value = results['insights'] as List<MLInsight>;
      spendingPattern.value = results['pattern'] as SpendingPattern?;
      predictions.value = results['predictions'] as Map<DateTime, double>;
    } catch (e) {
      debugPrint('ML Analysis Error: $e');
    } finally {
      isAnalyzing.value = false;
    }
  }

  // Static function for compute isolate
  static Map<String, dynamic> _performMLAnalysis(
    List<TransactionData> transactions,
  ) {
    return {
      'insights': MLService.generateInsightsIsolate(transactions),
      'pattern': MLService.analyzeSpendingPatternIsolate(transactions),
      'predictions': MLService.predictNextWeekSpendingIsolate(transactions),
    };
  }

  // Expose cached values as getters
  List<LocalTransaction> get filteredTransactions => _filteredTransactions;
  Map<String, double> get spendingByCategory => _spendingByCategory;
  double get totalIncome => _totalIncome.value;
  double get totalExpenses => _totalExpenses.value;
  Map<DateTime, double> get dailySpendingTrend => _dailySpendingTrend;
  List<MapEntry<String, double>> get topSpendingCategories =>
      _topSpendingCategories;

  double get netBalance => totalIncome - totalExpenses;

  double get savingsRate {
    if (totalIncome == 0) return 0.0;
    return ((totalIncome - totalExpenses) / totalIncome) * 100;
  }

  double get averageDailySpending {
    if (_filteredTransactions.isEmpty) return 0.0;
    final expenses = _filteredTransactions
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
      case 'Anne':
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
