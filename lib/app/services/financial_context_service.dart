import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/core/utils/mutex.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:logger/logger.dart';
import 'dart:async'; // Added import for StreamSubscription

class FinancialContextService extends GetxService {
  // Observables for all financial data
  final RxList<LocalTransaction> allTransactions = <LocalTransaction>[].obs;
  final RxList<Job> allJobs = <Job>[].obs;
  final RxList<Budget> allBudgets = <Budget>[].obs;
  final RxList<Debt> allDebts = <Debt>[].obs;
  final RxList<FinancialGoal> allGoals = <FinancialGoal>[].obs;
  final RxList<Category> allCategories = <Category>[].obs;
  final RxList<RecurringTransaction> allRecurringTransactions =
      <RecurringTransaction>[].obs;

  // Internal caches for optimized queries (O(1) lookups instead of O(N) filters)
  final RxMap<String, List<LocalTransaction>> _transactionsByCategory =
      <String, List<LocalTransaction>>{}.obs;
  final RxMap<String, List<LocalTransaction>> _transactionsByDebt =
      <String, List<LocalTransaction>>{}.obs;

  // Computed metrics
  final RxDouble currentBalance = 0.0.obs;
  final RxDouble totalMonthlyIncome = 0.0.obs;
  final RxDouble totalMonthlyExpenses = 0.0.obs;
  final RxDouble totalOutstandingDebt = 0.0.obs;
  final RxDouble totalMonthlyDebtPayments = 0.0.obs;
  final RxDouble averageMonthlySavings = 0.0.obs; // Placeholder
  final RxInt financialHealthScore = 0.obs; // Placeholder
  final RxDouble totalAllocatedBalance =
      0.0.obs; // Funds allocated to envelopes

  // Computed: Free Balance (Current - Allocated)
  double get freeBalance => currentBalance.value - totalAllocatedBalance.value;

  // Synchronization locks for critical operations
  final _balanceLock = Mutex();
  final _debtLock = Mutex();
  final _logger = Logger();

  // Stream subscriptions for Hive box watches
  final List<StreamSubscription> _subscriptions = [];
  // GetX Workers for everAll
  final List<Worker> _workers = [];
  final isInitialized =
      false.obs; // New: Tracks initial data loading completion

  @override
  void onInit() {
    super.onInit();
    _initListeners();
    // New: Load data asynchronously and mark as initialized after completion
    _loadAllData().then((_) {
      isInitialized.value = true;
      _logger.i('FinancialContextService initialized and all data loaded.');
    });
  }

  @override
  void onClose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  /// Manually clears all in-memory data.
  /// Call this when resetting the app state without a full process restart.
  void clearMemory() {
    allTransactions.clear();
    allJobs.clear();
    allBudgets.clear();
    allDebts.clear();
    allGoals.clear();
    allCategories.clear();
    allRecurringTransactions.clear();
    currentBalance.value = 0.0;
    totalMonthlyIncome.value = 0.0;
    totalMonthlyExpenses.value = 0.0;
    totalOutstandingDebt.value = 0.0;
    totalMonthlyDebtPayments.value = 0.0;
    averageMonthlySavings.value = 0.0;
    _transactionsByCategory.clear();
    _transactionsByDebt.clear();
    _logger.i('FinancialContextService memory cleared.');
  }

  void _initListeners() {
    // Listen to Isar transaction changes (primary source)
    _subscriptions.add(IsarService.watchTransactions().listen((transactions) {
      _onIsarTransactionsChanged(transactions);
    }));
    _subscriptions
        .add(Hive.box<Job>('jobBox').watch().listen((_) => _loadJobs()));
    _subscriptions.add(
        Hive.box<Budget>('budgetBox').watch().listen((_) => _loadBudgets()));
    _subscriptions
        .add(Hive.box<Debt>('debtBox').watch().listen((_) => _loadDebts()));
    _subscriptions.add(Hive.box<FinancialGoal>('financialGoalBox')
        .watch()
        .listen((_) => _loadGoals()));
    _subscriptions.add(Hive.box<Category>('categoryBox')
        .watch()
        .listen((_) => _loadCategories()));
    _subscriptions.add(Hive.box<RecurringTransaction>('recurringTransactionBox')
        .watch()
        .listen((_) => _loadRecurringTransactions()));

    // Targeted updates with debounce
    // 1. Transactions change -> Balance, Income, Savings, and Debt Reconciliation
    debounce(
      allTransactions,
      (_) async {
        await _calculateCurrentBalance();
        _calculateMonthlyIncomeAndExpenses();
        _calculateAverageMonthlySavings();
        _reconcileDebtAmounts();
      },
      time: const Duration(milliseconds: 500),
    );

    // 2. Debts change -> Debt Totals and Validation
    debounce(
      allDebts,
      (_) {
        _calculateDebtTotals();
        // Also reconcile to ensure originalAmount/remaining consistency
        // But doing it here might trigger another update if we save.
        // The logic in _reconcileDebtAmounts checks for diff > 0.01, so it stabilizes.
        _reconcileDebtAmounts();
      },
      time: const Duration(milliseconds: 500),
    );
  }

  Future<void> _loadAllData() async {
    // Changed to async Future<void>
    _logger.i('FinancialContextService: Starting _loadAllData.');
    _loadTransactions();
    _loadJobs();
    _loadBudgets();
    _loadDebts();
    _loadGoals();
    _loadCategories();
    _loadRecurringTransactions();
    // Schedule metrics recalculation asynchronously
    await Future.microtask(() => _recalculateMetrics()); // Await recalculation
    _logger.i('FinancialContextService: _loadAllData completed.');
  }

  void _loadTransactions() async {
    // Load transactions from Isar (primary source)
    final transactions = await IsarService.getAllTransactions();
    _logger.i(
        'ISAR DEBUG: Loaded ${transactions.length} total tx. Hidden: ${transactions.where((t) => t.isHidden).length}');
    _onIsarTransactionsChanged(transactions.where((t) => !t.isHidden).toList());
  }

  /// Handle Isar transaction stream updates
  void _onIsarTransactionsChanged(List<LocalTransaction> transactions) {
    allTransactions.assignAll(transactions.where((t) => !t.isHidden));

    // Update caches
    final byCategory = <String, List<LocalTransaction>>{};
    final byDebt = <String, List<LocalTransaction>>{};

    for (var tx in transactions) {
      if (tx.categoryId != null) {
        byCategory.putIfAbsent(tx.categoryId!, () => []).add(tx);
      }
      if (tx.linkedDebtId != null) {
        byDebt.putIfAbsent(tx.linkedDebtId!, () => []).add(tx);
      }
    }

    _transactionsByCategory.assignAll(byCategory);
    _transactionsByDebt.assignAll(byDebt);
  }

  void _loadJobs() => allJobs.assignAll(Hive.box<Job>('jobBox')
      .values
      .toList()
      .where((job) => job.isActive)
      .toList());
  void _loadBudgets() =>
      allBudgets.assignAll(Hive.box<Budget>('budgetBox').values.toList());
  void _loadDebts() =>
      allDebts.assignAll(Hive.box<Debt>('debtBox').values.toList());
  void _loadGoals() => allGoals
      .assignAll(Hive.box<FinancialGoal>('financialGoalBox').values.toList());
  void _loadCategories() => allCategories
      .assignAll(Hive.box<Category>('categoryBox').values.toList());
  void _loadRecurringTransactions() => allRecurringTransactions.assignAll(
      Hive.box<RecurringTransaction>('recurringTransactionBox')
          .values
          .toList());

  Future<void> _recalculateMetrics() async {
    await _reconcileDebtAmounts(); // Ensure consistency before calculation
    await _calculateCurrentBalance();
    _calculateMonthlyIncomeAndExpenses();
    _calculateDebtTotals();
    _calculateAverageMonthlySavings();
    // financialHealthScore.value = _mlService.getFinancialHealthScore(this); // Requires MLService
  }

  Future<void> _reconcileDebtAmounts() async {
    try {
      // Self-healing: Ensure debt.remainingAmount matches the sum of linked transactions
      await _debtLock.protect(() async {
        for (var debt in allDebts) {
          // Find all linked repayment transactions using cache (O(1) lookup)
          final linkedTxs = _transactionsByDebt[debt.id] ?? [];

          double totalRepaid = 0.0;

          for (var tx in linkedTxs) {
            // CRITICAL: Only count repayments based on debt type
            bool isValidRepayment = false;

            if (debt.type == DebtType.lent) {
              // When we LENT money, repayments are INCOME transactions
              // (friend paying us back)
              isValidRepayment = tx.type == TransactionType.income;
            } else if (debt.type == DebtType.borrowed) {
              // When we BORROWED money, repayments are EXPENSE transactions
              // (us paying back)
              isValidRepayment = tx.type == TransactionType.expense;
            }

            // Log unexpected types
            if (!isValidRepayment && tx.linkedDebtId == debt.id) {
              _logger.w('Unexpected transaction type for debt repayment: '
                  'Debt type: ${debt.type}, TX type: ${tx.type}, TX: $tx');
            }

            if (isValidRepayment) {
              totalRepaid += tx.amount;
            }
          }

          final calculatedRemaining = (debt.originalAmount - totalRepaid)
              .clamp(0.0, double.infinity); // Prevent negative

          // NEW: Check if reconciliation is needed
          if ((debt.remainingAmount - calculatedRemaining).abs() > 0.01) {
            debt.remainingAmount = calculatedRemaining;

            try {
              // NEW: Add error handling
              await debt.save();

              _logger.i('Debt reconciled: ${debt.personName}, '
                  'Remaining: $calculatedRemaining');

              // Check if debt is now paid off
              if (calculatedRemaining <= 0 && !debt.isPaidOff) {
                _logger.i('Debt paid off: ${debt.personName}');
              }
            } catch (e, stackTrace) {
              // NEW: Proper error handling
              _logger.e('Failed to save reconciled debt: $e',
                  stackTrace: stackTrace);
              // Rethrow or handle appropriately
              rethrow;
            }
          }
        }
      });
    } catch (e, stackTrace) {
      _logger.e('Debt reconciliation failed: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _calculateCurrentBalance() async {
    // Protect with mutex to prevent race conditions
    await _balanceLock.protect(() async {
      double balance = 0.0;

      // Validate transaction types
      for (var transaction in allTransactions) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else if (transaction.type == TransactionType.expense) {
          balance -= transaction.amount;
        } else {
          // Log unexpected types
          _logger.w('Unexpected transaction type: ${transaction.type}');
        }
      }

      currentBalance.value = balance;
    });
  }

  void _calculateMonthlyIncomeAndExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double income = 0.0;
    double expenses = 0.0;

    // Income from transactions (include first day of month!)
    income += allTransactions
        .where((tx) =>
            tx.type == TransactionType.income &&
            !tx.date.isBefore(startOfMonth) &&
            tx.date.isBefore(endOfMonth))
        .fold(0.0, (sum, tx) => sum + tx.amount);

    // Expenses from transactions (include first day of month!)
    expenses += allTransactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            !tx.date.isBefore(startOfMonth) &&
            tx.date.isBefore(endOfMonth))
        .fold(0.0, (sum, tx) => sum + tx.amount);

    totalMonthlyIncome.value = income;
    totalMonthlyExpenses.value = expenses;
  }

  void _calculateDebtTotals() {
    double outstanding = 0.0;
    double monthlyPayments = 0.0;

    for (var debt in allDebts) {
      if (!debt.isPaidOff) {
        outstanding += debt.remainingAmount;

        if (debt.minPayment > 0) {
          monthlyPayments += debt.minPayment;
        } else {
          final dueDate = debt.dueDate;
          if (dueDate != null && dueDate.isAfter(DateTime.now())) {
            // If no min payment set but has due date, estimate based on time remaining
            final months =
                (dueDate.difference(DateTime.now()).inDays / 30).ceil();
            if (months > 0) {
              monthlyPayments += debt.remainingAmount / months;
            } else {
              monthlyPayments += debt.remainingAmount; // Due now/soon
            }
          }
        }
      }
    }
    totalOutstandingDebt.value = outstanding;
    totalMonthlyDebtPayments.value = monthlyPayments;
  }

  void _calculateAverageMonthlySavings() {
    final now = DateTime.now();
    double totalSavings = 0.0;
    int monthsCounted = 0;

    // Calculate for last 3 months including current
    for (int i = 0; i < 3; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final start = DateTime(targetMonth.year, targetMonth.month, 1);
      final end =
          DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

      final monthIncome = allTransactions
          .where((tx) =>
              tx.type == TransactionType.income &&
              tx.date.isAfter(start) &&
              tx.date.isBefore(end))
          .fold(0.0, (sum, tx) => sum + tx.amount);

      final monthExpenses = allTransactions
          .where((tx) =>
              tx.type == TransactionType.expense &&
              tx.date.isAfter(start) &&
              tx.date.isBefore(end))
          .fold(0.0, (sum, tx) => sum + tx.amount);

      // Only count months that have activity
      if (monthIncome > 0 || monthExpenses > 0) {
        totalSavings += (monthIncome - monthExpenses);
        monthsCounted++;
      }
    }

    if (monthsCounted > 0) {
      averageMonthlySavings.value = totalSavings / monthsCounted;
    } else {
      averageMonthlySavings.value = 0.0;
    }
  }

  /// Public method to trigger balance recalculation
  /// Useful when external operations modify transactions
  Future<void> calculateBalance() async {
    await _calculateCurrentBalance();
  }

  // Cross-feature query methods (examples)
  Category? getCategoryById(String categoryId) {
    return allCategories.firstWhereOrNull((cat) => cat.id == categoryId);
  }

  double getBudgetedAmountForCategory(String categoryId, int year, int month) {
    return allBudgets
            .firstWhereOrNull((b) =>
                b.categoryId == categoryId &&
                b.year == year &&
                b.month == month)
            ?.amount ??
        0.0;
  }

  double getSpentAmountForCategory(String categoryId, int year, int month) {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions = _transactionsByCategory[categoryId] ?? [];

    return transactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            !tx.date.isBefore(startOfMonth) &&
            tx.date.isBefore(endOfMonth))
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getBudgetPerformance(String categoryId, int year, int month) {
    final budgeted = getBudgetedAmountForCategory(categoryId, year, month);
    final spent = getSpentAmountForCategory(categoryId, year, month);
    return budgeted - spent; // Positive means under budget, negative means over
  }

  Debt? getDebtById(String debtId) {
    return allDebts.firstWhereOrNull((debt) => debt.id == debtId);
  }

  double getTotalOutstandingDebt() {
    return allDebts
        .where((debt) => !debt.isPaidOff)
        .fold(0.0, (sum, debt) => sum + debt.remainingAmount);
  }

  double getTotalMonthlyDebtPayments() {
    return allDebts
        .where((debt) => !debt.isPaidOff)
        .fold(0.0, (sum, debt) => sum + debt.minPayment);
  }

  List<Debt> getActiveDebts() {
    return allDebts.where((debt) => !debt.isPaidOff).toList();
  }

  /// Updates the total amount allocated to envelopes/goals.
  /// Called by EnvelopeService.
  void updateAllocatedBalance(double amount) {
    totalAllocatedBalance.value = amount;
  }
}
