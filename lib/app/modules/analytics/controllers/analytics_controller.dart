import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/financial_goal.dart'; // New import
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/services/financial_context_service.dart'; // New import
import 'package:koaa/app/services/ml_service.dart';
import 'package:uuid/uuid.dart';

enum TimeRange { month, year, all }

class ChartData {
  final String name;
  final double value;
  final int colorValue;

  ChartData(this.name, this.value, this.colorValue);
}

// New data class for budget comparison
class BudgetComparisonData {
  final String categoryName;
  final double budgetedAmount;
  final double spentAmount;
  final int colorValue;

  BudgetComparisonData({
    required this.categoryName,
    required this.budgetedAmount,
    required this.spentAmount,
    required this.colorValue,
  });
}

// New data class for debt timeline
class DebtTimelineData {
  final DateTime date;
  final double totalOutstanding;
  final double paymentsMade;

  DebtTimelineData({
    required this.date,
    required this.totalOutstanding,
    required this.paymentsMade,
  });
}

// New data class for goal progress tracking
class GoalProgressData {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final int colorValue;
  final DateTime? targetDate;

  GoalProgressData({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.colorValue,
    this.targetDate,
  });
}

class AnalyticsController extends GetxController {
  final transactions = <LocalTransaction>[].obs;
  final jobs = <Job>[].obs;

  final selectedYear = DateTime.now().year.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedTimeRange = TimeRange.month.obs;

  // Cached computed values
  final _filteredTransactions = <LocalTransaction>[].obs;
  final _spendingByCategory = <String, double>{}.obs;
  final _totalIncome = 0.0.obs;
  final _totalExpenses = 0.0.obs;
  final _chartData = <ChartData>[].obs;
  final _insights = <MLInsight>[].obs;
  final budgetComparison = <BudgetComparisonData>[].obs; // New observable
  final debtTimeline = <DebtTimelineData>[].obs; // New observable
  final goalProgress = <GoalProgressData>[].obs; // New observable

  // Trends
  final _previousTotalExpenses = 0.0.obs;

  // Savings goal (old model, will be replaced by FinancialGoal)
  final currentSavingsGoal = Rx<SavingsGoal?>(null);

  final _mlService = MLService();
  late FinancialContextService _financialContextService; // New service

  // Workers for cleanup
  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    _financialContextService =
        Get.find<FinancialContextService>(); // Inject service
    _initializeData();

    // Listen to changes and store workers for cleanup
    _workers.add(ever(selectedYear, (_) => _updateCachedData()));
    _workers.add(ever(selectedMonth, (_) => _updateCachedData()));
    _workers.add(ever(selectedTimeRange, (_) => _updateCachedData()));

    // Listen to financial context changes to refresh analytics data
    _workers.add(ever(
        _financialContextService.allTransactions, (_) => _updateCachedData()));
    _workers.add(
        ever(_financialContextService.allJobs, (_) => _updateCachedData()));
    _workers.add(
        ever(_financialContextService.allBudgets, (_) => _updateCachedData()));
    _workers.add(ever(
        _financialContextService.allCategories, (_) => _updateCachedData()));
    _workers.add(ever(_financialContextService.allDebts,
        (_) => _updateCachedData())); // Listen to debts
    _workers.add(ever(_financialContextService.allGoals,
        (_) => _updateCachedData())); // Listen to goals

    _updateCachedData();
  }

  @override
  void onClose() {
    // Dispose all workers
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    // Clear all observables
    transactions.clear();
    jobs.clear();
    _filteredTransactions.clear();
    _spendingByCategory.clear();
    _chartData.clear();
    _insights.clear();
    budgetComparison.clear();
    debtTimeline.clear();
    goalProgress.clear();

    super.onClose();
  }

  void _initializeData() {
    // Get data directly from FinancialContextService
    transactions.assignAll(_financialContextService.allTransactions);
    jobs.assignAll(_financialContextService.allJobs);

    // No need to listen to individual Hive boxes here directly, FinancialContextService does that
    // and triggers updates through its observables which we listen to above.

    _loadCurrentSavingsGoal(); // Keep for backward compatibility for now
  }

  void _loadCurrentSavingsGoal() {
    final savingsBox = Hive.box<SavingsGoal>('savingsGoalBox');
    final goals = savingsBox.values.where(
      (g) => g.year == selectedYear.value && g.month == selectedMonth.value,
    );
    currentSavingsGoal.value = goals.isEmpty ? null : goals.first;
  }

  void _updateCachedData() {
    _updateFilteredTransactions();
    _updateSpendingByCategory();
    _updateTotals();
    _updateChartDataLogic();
    _updateInsights();
    _updateBudgetComparison();
    _updateDebtTimeline();
    _updateGoalProgress(); // New call
    _loadCurrentSavingsGoal(); // Re-evaluate current savings goal as month/year might change
  }

  void _updateInsights() {
    // We pass ALL transactions to ML service for better pattern detection
    // regardless of the current view filter.
    _insights.value = _mlService.generateInsights(transactions);
  }

  void _updateFilteredTransactions() {
    DateTime start, end;

    if (selectedTimeRange.value == TimeRange.month) {
      start = DateTime(selectedYear.value, selectedMonth.value, 1);
      end =
          DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);
    } else if (selectedTimeRange.value == TimeRange.year) {
      start = DateTime(selectedYear.value, 1, 1);
      end = DateTime(selectedYear.value, 12, 31, 23, 59, 59);
    } else {
      // All Time
      start = DateTime(2000);
      end = DateTime(2100);
    }

    _filteredTransactions.value = transactions
        .where((t) =>
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Update Comparison (Previous Period)
    DateTime prevStart, prevEnd;
    if (selectedTimeRange.value == TimeRange.month) {
      // Previous Month
      final prevDate = DateTime(selectedYear.value, selectedMonth.value - 1, 1);
      prevStart = DateTime(prevDate.year, prevDate.month, 1);
      prevEnd = DateTime(prevDate.year, prevDate.month + 1, 0, 23, 59, 59);
    } else if (selectedTimeRange.value == TimeRange.year) {
      // Previous Year
      prevStart = DateTime(selectedYear.value - 1, 1, 1);
      prevEnd = DateTime(selectedYear.value - 1, 12, 31, 23, 59, 59);
    } else {
      prevStart = DateTime(2000);
      prevEnd = DateTime(2000);
    }

    final prevTransactions = transactions.where((t) =>
        t.type == TransactionType.expense &&
        t.date.isAfter(prevStart) &&
        t.date.isBefore(prevEnd));

    _previousTotalExpenses.value =
        prevTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  void _updateSpendingByCategory() {
    final categories = <String, double>{};
    final categoriesController = Get.find<CategoriesController>();

    for (var transaction in _filteredTransactions) {
      if (transaction.type == TransactionType.expense) {
        String categoryName = 'Autre';

        if (transaction.categoryId != null) {
          final cat = categoriesController.categories
              .firstWhereOrNull((c) => c.id == transaction.categoryId);
          if (cat != null) categoryName = cat.name;
        } else if (transaction.category != null) {
          categoryName = transaction.category!.displayName;
        }

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

  // Memoization cache for chart data
  Map<String, dynamic>? _chartDataCache;

  void _updateChartDataLogic() {
    // Create cache key from spending by category
    final cacheKey =
        _spendingByCategory.entries.map((e) => '${e.key}:${e.value}').join(',');

    // Check if cache is still valid
    if (_chartDataCache != null && _chartDataCache!['key'] == cacheKey) {
      // Cache hit - use cached data
      _chartData.value = _chartDataCache!['data'] as List<ChartData>;
      return;
    }

    // Cache miss - recalculate
    final sorted = _spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoriesController = Get.find<CategoriesController>();
    final List<ChartData> data = [];

    int getColor(String name) {
      if (name == 'Autre') return 0xFF9E9E9E;
      final cat = categoriesController.categories
          .firstWhereOrNull((c) => c.name == name);
      if (cat != null) return cat.colorValue;
      return 0xFF4C6EF5;
    }

    if (sorted.length <= 5) {
      for (var entry in sorted) {
        data.add(ChartData(entry.key, entry.value, getColor(entry.key)));
      }
    } else {
      final top4 = sorted.take(4);
      for (var entry in top4) {
        data.add(ChartData(entry.key, entry.value, getColor(entry.key)));
      }
      final others =
          sorted.skip(4).fold(0.0, (sum, entry) => sum + entry.value);
      data.add(ChartData('Autres', others, 0xFF9E9E9E));
    }

    // Update cache
    _chartDataCache = {
      'key': cacheKey,
      'data': data,
    };

    _chartData.value = data;
  }

  void _updateBudgetComparison() {
    // Only show budget comparison for month view
    if (selectedTimeRange.value != TimeRange.month) {
      budgetComparison.clear();
      return;
    }

    final categoriesController = Get.find<CategoriesController>();
    final List<BudgetComparisonData> data = [];

    // Filter transactions for the current period
    final currentPeriodTransactions = _filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    // Get budgets for the current selected month
    final currentMonthBudgets = _financialContextService.allBudgets
        .where((b) =>
            b.year == selectedYear.value && b.month == selectedMonth.value)
        .toList();

    for (var budget in currentMonthBudgets) {
      final category = categoriesController.categories
          .firstWhereOrNull((c) => c.id == budget.categoryId);
      if (category != null) {
        final spentAmount = currentPeriodTransactions
            .where((t) => t.categoryId == category.id)
            .fold(0.0, (sum, t) => sum + t.amount);

        data.add(BudgetComparisonData(
          categoryName: category.name,
          budgetedAmount: budget.amount,
          spentAmount: spentAmount,
          colorValue: category.colorValue,
        ));
      }
    }
    budgetComparison.assignAll(data);
  }

  void _updateDebtTimeline() {
    debtTimeline.clear();

    // Only show debt timeline for year or all time view
    if (selectedTimeRange.value == TimeRange.month) {
      debtTimeline.clear();
      return;
    }

    // Determine the relevant time frame for the timeline
    DateTime startDate;
    DateTime endDate = DateTime.now();

    if (selectedTimeRange.value == TimeRange.year) {
      startDate = DateTime(selectedYear.value, 1, 1);
      endDate = DateTime(selectedYear.value, 12, 31, 23, 59, 59);
    } else {
      // TimeRange.all
      final allDebts = _financialContextService.allDebts;
      if (allDebts.isNotEmpty) {
        startDate = allDebts
            .map((d) => d.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        startDate = DateTime(startDate.year, startDate.month,
            1); // Start from the beginning of that month
      } else {
        debtTimeline.clear();
        return; // No debts, no timeline
      }
    }

    // Aggregate data by month
    DateTime currentMonthIterator =
        DateTime(startDate.year, startDate.month, 1);
    final monthEnd = DateTime(endDate.year, endDate.month + 1, 0);

    while (currentMonthIterator.isBefore(monthEnd)) {
      double totalOutstanding = 0.0;
      double paymentsMade = 0.0;

      for (var debt in _financialContextService.allDebts) {
        // Only consider debts that existed by the start of currentMonthIterator
        if (debt.createdAt
            .isBefore(currentMonthIterator.add(const Duration(days: 1)))) {
          double effectiveOutstanding = debt.originalAmount;

          // Subtract payments made for this debt up to the current month iterator
          for (var tx in _financialContextService.allTransactions) {
            if (tx.type == TransactionType.expense &&
                tx.date.isBefore(
                    currentMonthIterator.add(const Duration(days: 1))) &&
                tx.linkedDebtId == debt.id) {
              effectiveOutstanding -= tx.amount;
            }
          }
          totalOutstanding += effectiveOutstanding;
        }
      }

      // Calculate payments made *in* the current month
      paymentsMade = _financialContextService.allTransactions
          .where((tx) =>
              tx.date.year == currentMonthIterator.year &&
              tx.date.month == currentMonthIterator.month &&
              tx.type == TransactionType.expense &&
              tx.linkedDebtId != null)
          .fold(0.0, (sum, tx) => sum + tx.amount);

      debtTimeline.add(DebtTimelineData(
        date: currentMonthIterator,
        totalOutstanding: totalOutstanding.isNegative
            ? 0.0
            : totalOutstanding, // Ensure outstanding is not negative
        paymentsMade: paymentsMade,
      ));

      currentMonthIterator = DateTime(
          currentMonthIterator.year, currentMonthIterator.month + 1, 1);
    }

    debtTimeline.sort((a, b) => a.date.compareTo(b.date));
  }

  void _updateGoalProgress() {
    goalProgress.clear();
    // Only show goal progress for month view or all time view
    if (selectedTimeRange.value == TimeRange.year) {
      goalProgress.clear();
      return;
    }

    final allGoals = _financialContextService.allGoals;
    final goalsToDisplay = (selectedTimeRange.value == TimeRange.month)
        ? allGoals
            .where((goal) => goal.status == GoalStatus.active)
            .toList() // For month view, maybe just active ones
        : allGoals.toList(); // For all time, show all goals

    for (var goal in goalsToDisplay) {
      goalProgress.add(GoalProgressData(
        id: goal.id,
        title: goal.title,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        progressPercentage: goal.progressPercentage,
        colorValue: goal.colorValue ?? Get.theme.primaryColor.value,
        targetDate: goal.targetDate,
      ));
    }
  }

  Future<void> addJob({
    required String name,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime paymentDate,
  }) async {
    final jobBox = Hive.box<Job>('jobBox');
    final job = Job(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      frequency: frequency,
      paymentDate: paymentDate,
    );
    await jobBox.put(job.id, job);
  }

  Future<void> updateJob(Job job) async {
    final jobBox = Hive.box<Job>('jobBox');
    await jobBox.put(job.id, job);
  }

  Future<void> deleteJob(String jobId) async {
    final jobBox = Hive.box<Job>('jobBox');
    final job = jobBox.get(jobId);
    if (job != null) {
      final updatedJob = job.copyWith(isActive: false);
      await jobBox.put(jobId, updatedJob);
    }
  }

  Future<void> setSavingsGoal(double targetAmount) async {
    final savingsBox = Hive.box<SavingsGoal>('savingsGoalBox');
    final existingGoals = savingsBox.values.where(
      (g) => g.year == selectedYear.value && g.month == selectedMonth.value,
    );
    final existingGoal = existingGoals.isEmpty ? null : existingGoals.first;

    if (existingGoal != null) {
      final updated = existingGoal.copyWith(targetAmount: targetAmount);
      await savingsBox.put(existingGoal.id, updated);
    } else {
      final goal = SavingsGoal(
        id: const Uuid().v4(),
        targetAmount: targetAmount,
        year: selectedYear.value,
        month: selectedMonth.value,
      );
      await savingsBox.put(goal.id, goal);
    }
  }

  void navigatePrevious() {
    final minYear = 2020; // Prevent navigating to very old dates
    final currentYear = DateTime.now().year;

    if (selectedTimeRange.value == TimeRange.month) {
      // Prevent going before minYear
      if (selectedYear.value == minYear && selectedMonth.value == 1) {
        return; // Can't go further back
      }

      if (selectedMonth.value == 1) {
        selectedMonth.value = 12;
        selectedYear.value--;
      } else {
        selectedMonth.value--;
      }
    } else if (selectedTimeRange.value == TimeRange.year) {
      // Prevent going before minYear
      if (selectedYear.value > minYear) {
        selectedYear.value--;
      }
    }
  }

  void navigateNext() {
    final currentYear = DateTime.now().year;

    if (selectedTimeRange.value == TimeRange.month) {
      // Prevent going beyond current month
      if (selectedYear.value == currentYear &&
          selectedMonth.value == DateTime.now().month) {
        return; // Can't go further forward
      }

      if (selectedMonth.value == 12) {
        selectedMonth.value = 1;
        selectedYear.value++;
      } else {
        selectedMonth.value++;
      }

      // Ensure we don't go beyond current date
      if (selectedYear.value > currentYear ||
          (selectedYear.value == currentYear &&
              selectedMonth.value > DateTime.now().month)) {
        selectedYear.value = currentYear;
        selectedMonth.value = DateTime.now().month;
      }
    } else if (selectedTimeRange.value == TimeRange.year) {
      // Prevent going beyond current year
      if (selectedYear.value < currentYear) {
        selectedYear.value++;
      }
    }
  }

  bool get canNavigate => selectedTimeRange.value != TimeRange.all;

  void navigateToCurrentMonth() {
    selectedYear.value = DateTime.now().year;
    selectedMonth.value = DateTime.now().month;
  }

  void setTimeRange(TimeRange range) {
    selectedTimeRange.value = range;
  }

  // Getters
  List<LocalTransaction> get filteredTransactions => _filteredTransactions;
  Map<String, double> get spendingByCategory => _spendingByCategory;
  double get totalIncome => _totalIncome.value;
  double get totalExpenses => _totalExpenses.value;
  List<ChartData> get chartData => _chartData;
  List<MLInsight> get insights => _insights;
  double get previousTotalExpenses => _previousTotalExpenses.value;

  double get netBalance => totalIncome - totalExpenses;

  double get savingsRate {
    if (totalIncome == 0) return 0.0;
    return netBalance / totalIncome;
  }

  ({String label, int color}) get savingsStatus {
    if (netBalance < 0) {
      return (label: 'Déficit Attention 🚨', color: 0xFFEF4444); // Red
    }
    if (savingsRate < 0.20) {
      return (label: 'Budget Serré ⚠️', color: 0xFFF59E0B); // Orange
    }
    return (label: 'Épargne Saine 🚀', color: 0xFF10B981); // Green
  }

  // Old savings progress, will be replaced by goalProgress observable
  double get savingsProgress {
    final goal = currentSavingsGoal.value;
    if (goal == null || goal.targetAmount == 0) return 0.0;
    return (netBalance / goal.targetAmount) * 100;
  }

  String get currentPeriodName {
    if (selectedTimeRange.value == TimeRange.year) {
      return '${selectedYear.value}';
    }
    if (selectedTimeRange.value == TimeRange.all) {
      return 'Tout';
    }
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[selectedMonth.value - 1];
  }

  String get currentMonthName {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[selectedMonth.value - 1];
  }

  double get expenseTrendPercentage {
    if (previousTotalExpenses == 0) return 0;
    return ((totalExpenses - previousTotalExpenses) / previousTotalExpenses) *
        100;
  }
}

