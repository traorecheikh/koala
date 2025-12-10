import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/services/ml_service.dart';
import 'package:uuid/uuid.dart';

enum TimeRange { month, year, all }

class ChartData {
  final String name;
  final double value;
  final int colorValue;
  
  ChartData(this.name, this.value, this.colorValue);
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
  
  // Trends
  final _previousTotalExpenses = 0.0.obs;

  // Savings goal
  final currentSavingsGoal = Rx<SavingsGoal?>(null);
  
  final _mlService = MLService();

  @override
  void onInit() {
    super.onInit();
    _initializeData();

    // Listen to changes
    ever(selectedYear, (_) => _updateCachedData());
    ever(selectedMonth, (_) => _updateCachedData());
    ever(selectedTimeRange, (_) => _updateCachedData());

    _updateCachedData();
  }

  void _initializeData() {
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    transactions.assignAll(transactionBox.values.toList());
    transactionBox.watch().listen((_) {
      transactions.assignAll(transactionBox.values.toList());
      _updateCachedData();
    });

    final jobBox = Hive.box<Job>('jobBox');
    jobs.assignAll(jobBox.values.where((j) => j.isActive).toList());
    jobBox.watch().listen((_) {
      jobs.assignAll(jobBox.values.where((j) => j.isActive).toList());
      _updateCachedData();
    });

    _loadCurrentSavingsGoal();
    final savingsBox = Hive.box<SavingsGoal>('savingsGoalBox');
    savingsBox.watch().listen((_) => _loadCurrentSavingsGoal());
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
    _loadCurrentSavingsGoal();
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
      end = DateTime(selectedYear.value, selectedMonth.value + 1, 0, 23, 59, 59);
    } else if (selectedTimeRange.value == TimeRange.year) {
      start = DateTime(selectedYear.value, 1, 1);
      end = DateTime(selectedYear.value, 12, 31, 23, 59, 59);
    } else {
      // All Time
      start = DateTime(2000);
      end = DateTime(2100);
    }

    _filteredTransactions.value = transactions
        .where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
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
    
    final prevTransactions = transactions
        .where((t) => t.date.isAfter(prevStart) && t.date.isBefore(prevEnd));
        
    _previousTotalExpenses.value = prevTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _updateSpendingByCategory() {
    final categories = <String, double>{};
    final categoriesController = Get.find<CategoriesController>();
    
    for (var transaction in _filteredTransactions) {
      if (transaction.type == TransactionType.expense) {
        String categoryName = 'Autre';
        
        if (transaction.categoryId != null) {
          final cat = categoriesController.categories.firstWhereOrNull((c) => c.id == transaction.categoryId);
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
    final transactionIncome = _filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    double jobIncome = 0;
    final monthlyJobIncome = jobs.fold(0.0, (sum, job) => sum + job.monthlyIncome);
    
    if (selectedTimeRange.value == TimeRange.month) {
      jobIncome = monthlyJobIncome;
    } else if (selectedTimeRange.value == TimeRange.year) {
      jobIncome = monthlyJobIncome * 12; 
    } else {
      jobIncome = monthlyJobIncome * 12; // Approx
    }

    _totalIncome.value = transactionIncome + jobIncome;

    _totalExpenses.value = _filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  void _updateChartDataLogic() {
    final sorted = _spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final categoriesController = Get.find<CategoriesController>();
    final List<ChartData> data = [];

    int getColor(String name) {
      if (name == 'Autre') return 0xFF9E9E9E; 
      final cat = categoriesController.categories.firstWhereOrNull((c) => c.name == name);
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
      final others = sorted.skip(4).fold(0.0, (sum, entry) => sum + entry.value);
      data.add(ChartData('Autres', others, 0xFF9E9E9E));
    }
    
    _chartData.value = data;
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

  void navigateToPreviousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
  }

  void navigateToNextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
  }

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
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return months[selectedMonth.value - 1];
  }
  
  String get currentMonthName { 
     const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return months[selectedMonth.value - 1];
  }
  
  double get expenseTrendPercentage {
    if (previousTotalExpenses == 0) return 0;
    return ((totalExpenses - previousTotalExpenses) / previousTotalExpenses) * 100;
  }
}
