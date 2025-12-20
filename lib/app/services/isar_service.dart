import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/local_transaction.dart';
import '../data/models/category.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/data/models/envelope.dart';

/// Service for managing Isar database instance.
/// Handles initialization and provides access to the Isar instance.
class IsarService {
  static Isar? _isar;
  static bool _isInitialized = false;

  /// Get the Isar instance. Throws if not initialized.
  static Isar get instance {
    if (_isar == null) {
      throw StateError('IsarService not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Check if Isar is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Isar with required schemas
  static Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = Isar.open(
      schemas: [
        LocalTransactionSchema,
        CategorySchema,
        BudgetSchema,
        FinancialGoalSchema,
        RecurringTransactionSchema,
        DebtSchema,
        JobSchema,
        LocalUserSchema,
        SavingsGoalSchema,
        EnvelopeSchema,
      ],
      directory: dir.path,
      name: 'koala_isar_v5',
    );

    _isInitialized = true;
  }

  /// Close the Isar instance
  static Future<void> close() async {
    _isar?.close();
    _isar = null;
    _isInitialized = false;
  }

  /// Get the LocalTransaction collection
  static IsarCollection<String, LocalTransaction> get transactions {
    return instance.localTransactions;
  }

  /// Add a transaction (synchronous write for isolate compatibility)
  static void addTransaction(LocalTransaction transaction) {
    instance.write((isar) {
      isar.localTransactions.put(transaction);
    });
  }

  /// Add multiple transactions (synchronous for migration compatibility)
  static void addTransactions(List<LocalTransaction> txns) {
    instance.write((isar) {
      isar.localTransactions.putAll(txns);
    });
  }

  /// Update a transaction
  static void updateTransaction(LocalTransaction transaction) {
    instance.write((isar) {
      isar.localTransactions.put(transaction);
    });
  }

  /// Delete a transaction by ID
  static bool deleteTransaction(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.localTransactions.delete(id);
    });
    return deleted;
  }

  /// Get all transactions
  static Future<List<LocalTransaction>> getAllTransactions() async {
    return await transactions.where().findAllAsync();
  }

  /// Get transactions by date range (uses filter on results)
  static Future<List<LocalTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = await transactions.where().findAllAsync();
    return all
        .where((tx) =>
            tx.date.isAfter(start.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Watch all transactions for changes
  static Stream<List<LocalTransaction>> watchTransactions() {
    return transactions.where().watch(fireImmediately: true);
  }

  /// Get transaction count
  static Future<int> getTransactionCount() async {
    final all = await transactions.where().findAllAsync();
    return all.length;
  }

  /// Clear all transactions (for testing/reset)
  static void clearTransactions() {
    instance.write((isar) {
      isar.localTransactions.clear();
    });
  }

  // ==================== Category CRUD ====================

  /// Get the Category collection
  static IsarCollection<String, Category> get categories {
    return instance.categorys;
  }

  /// Add a category
  static void addCategory(Category category) {
    instance.write((isar) {
      isar.categorys.put(category);
    });
  }

  /// Add multiple categories (for migration)
  static void addCategories(List<Category> cats) {
    instance.write((isar) {
      isar.categorys.putAll(cats);
    });
  }

  /// Update a category
  static void updateCategory(Category category) {
    instance.write((isar) {
      isar.categorys.put(category);
    });
  }

  /// Delete a category by ID
  static bool deleteCategory(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.categorys.delete(id);
    });
    return deleted;
  }

  /// Get all categories
  static Future<List<Category>> getAllCategories() async {
    return await categories.where().findAllAsync();
  }

  /// Get category by ID
  static Future<Category?> getCategoryById(String id) async {
    return categories.get(id);
  }

  /// Watch all categories for changes
  static Stream<List<Category>> watchCategories() {
    return categories.where().watch(fireImmediately: true);
  }

  /// Clear all categories (for testing/reset)
  static void clearCategories() {
    instance.write((isar) {
      isar.categorys.clear();
    });
  }

  // ==================== Budget CRUD ====================

  /// Get the Budget collection
  static IsarCollection<String, Budget> get budgets {
    return instance.budgets;
  }

  /// Add a budget
  static void addBudget(Budget budget) {
    instance.write((isar) {
      isar.budgets.put(budget);
    });
  }

  /// Add multiple budgets (for migration)
  static void addBudgets(List<Budget> budgetList) {
    instance.write((isar) {
      isar.budgets.putAll(budgetList);
    });
  }

  /// Update a budget
  static void updateBudget(Budget budget) {
    instance.write((isar) {
      isar.budgets.put(budget);
    });
  }

  /// Delete a budget by ID
  static bool deleteBudget(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.budgets.delete(id);
    });
    return deleted;
  }

  /// Get all budgets
  static Future<List<Budget>> getAllBudgets() async {
    return budgets.where().findAllAsync();
  }

  /// Get budget by ID
  static Future<Budget?> getBudgetById(String id) async {
    return budgets.get(id);
  }

  /// Watch all budgets for changes
  static Stream<List<Budget>> watchBudgets() {
    return budgets.where().watch(fireImmediately: true);
  }

  /// Clear all budgets (for testing/reset)
  static void clearBudgets() {
    instance.write((isar) {
      isar.budgets.clear();
    });
  }

  // ==================== FinancialGoal CRUD ====================

  /// Get the FinancialGoal collection
  static IsarCollection<String, FinancialGoal> get goals {
    return instance.financialGoals;
  }

  /// Add a goal
  static void addGoal(FinancialGoal goal) {
    instance.write((isar) {
      isar.financialGoals.put(goal);
    });
  }

  /// Add multiple goals (for migration)
  static void addGoals(List<FinancialGoal> goalList) {
    instance.write((isar) {
      isar.financialGoals.putAll(goalList);
    });
  }

  /// Update a goal
  static void updateGoal(FinancialGoal goal) {
    instance.write((isar) {
      isar.financialGoals.put(goal);
    });
  }

  /// Delete a goal by ID
  static bool deleteGoal(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.financialGoals.delete(id);
    });
    return deleted;
  }

  /// Get all goals
  static Future<List<FinancialGoal>> getAllGoals() async {
    return goals.where().findAllAsync();
  }

  /// Get goal by ID
  static Future<FinancialGoal?> getGoalById(String id) async {
    return goals.get(id);
  }

  /// Watch all goals for changes
  static Stream<List<FinancialGoal>> watchGoals() {
    return goals.where().watch(fireImmediately: true);
  }

  /// Clear all goals (for testing/reset)
  static void clearGoals() {
    instance.write((isar) {
      isar.financialGoals.clear();
    });
  }

  // ==================== RecurringTransaction CRUD ====================

  /// Get the RecurringTransaction collection
  static IsarCollection<String, RecurringTransaction>
      get recurringTransactions {
    return instance.recurringTransactions;
  }

  /// Add a recurring transaction
  static void addRecurringTransaction(RecurringTransaction rt) {
    instance.write((isar) {
      isar.recurringTransactions.put(rt);
    });
  }

  /// Add multiple recurring transactions (for migration)
  static void addRecurringTransactions(List<RecurringTransaction> rtList) {
    instance.write((isar) {
      isar.recurringTransactions.putAll(rtList);
    });
  }

  /// Update a recurring transaction
  static void updateRecurringTransaction(RecurringTransaction rt) {
    instance.write((isar) {
      isar.recurringTransactions.put(rt);
    });
  }

  /// Delete a recurring transaction by ID
  static bool deleteRecurringTransaction(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.recurringTransactions.delete(id);
    });
    return deleted;
  }

  /// Get all recurring transactions
  static Future<List<RecurringTransaction>>
      getAllRecurringTransactions() async {
    return recurringTransactions.where().findAllAsync();
  }

  /// Get recurring transaction by ID
  static Future<RecurringTransaction?> getRecurringTransactionById(
      String id) async {
    return recurringTransactions.get(id);
  }

  /// Watch all recurring transactions for changes
  static Stream<List<RecurringTransaction>> watchRecurringTransactions() {
    return recurringTransactions.where().watch(fireImmediately: true);
  }

  /// Watch only active recurring transactions
  static Stream<List<RecurringTransaction>> watchActiveRecurringTransactions() {
    return recurringTransactions
        .where()
        .isActiveEqualTo(true)
        .watch(fireImmediately: true);
  }

  /// Clear all recurring transactions (for testing/reset)
  static void clearRecurringTransactions() {
    instance.write((isar) {
      isar.recurringTransactions.clear();
    });
  }

  // ==================== Debt CRUD ====================

  /// Get the Debt collection
  static IsarCollection<String, Debt> get debts {
    return instance.debts;
  }

  /// Add a debt
  static void addDebt(Debt debt) {
    instance.write((isar) {
      isar.debts.put(debt);
    });
  }

  /// Add multiple debts (for migration)
  static void addDebts(List<Debt> debtList) {
    instance.write((isar) {
      isar.debts.putAll(debtList);
    });
  }

  /// Update a debt
  static void updateDebt(Debt debt) {
    instance.write((isar) {
      isar.debts.put(debt);
    });
  }

  /// Delete a debt by ID
  static bool deleteDebt(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.debts.delete(id);
    });
    return deleted;
  }

  /// Get all debts
  static Future<List<Debt>> getAllDebts() async {
    return debts.where().findAllAsync();
  }

  /// Get debt by ID
  static Future<Debt?> getDebtById(String id) async {
    return debts.get(id);
  }

  /// Watch all debts for changes
  static Stream<List<Debt>> watchDebts() {
    return debts.where().watch(fireImmediately: true);
  }

  /// Watch active debts (not paid off)
  static Stream<List<Debt>> watchActiveDebts() {
    return debts
        .where()
        .remainingAmountGreaterThan(0)
        .watch(fireImmediately: true);
  }

  /// Clear all debts (for testing/reset)
  static void clearDebts() {
    instance.write((isar) {
      isar.debts.clear();
    });
  }

  // ==================== Job CRUD ====================

  /// Get the Job collection
  static IsarCollection<String, Job> get jobs {
    return instance.jobs;
  }

  /// Add a job
  static void addJob(Job job) {
    instance.write((isar) {
      isar.jobs.put(job);
    });
  }

  /// Add multiple jobs (for migration)
  static void addJobs(List<Job> jobList) {
    instance.write((isar) {
      isar.jobs.putAll(jobList);
    });
  }

  /// Update a job
  static void updateJob(Job job) {
    instance.write((isar) {
      isar.jobs.put(job);
    });
  }

  /// Delete a job by ID
  static bool deleteJob(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.jobs.delete(id);
    });
    return deleted;
  }

  /// Get all jobs
  static Future<List<Job>> getAllJobs() async {
    return jobs.where().findAllAsync();
  }

  /// Get job by ID
  static Future<Job?> getJobById(String id) async {
    return jobs.get(id);
  }

  /// Watch all jobs for changes
  static Stream<List<Job>> watchJobs() {
    return jobs.where().watch(fireImmediately: true);
  }

  /// Watch only active jobs
  static Stream<List<Job>> watchActiveJobs() {
    // Filter in Dart to avoid 'IsarError: Illegal Argument' with bool index queries
    return jobs.where().watch(fireImmediately: true).map((events) {
      return events.where((j) => j.isActive).toList();
    });
  }

  /// Clear all jobs (for testing/reset)
  static void clearJobs() {
    instance.write((isar) {
      isar.jobs.clear();
    });
  }

  // ==================== LocalUser Methods (Singleton Pattern) ====================

  /// Save/update the user (singleton)
  static Future<void> saveUser(LocalUser user) async {
    instance.write((isar) {
      isar.localUsers.put(user);
    });
  }

  /// Get the user (singleton - returns first/only user)
  static LocalUser? getUser() {
    return instance.localUsers.where().findFirst();
  }

  /// Watch the user for changes
  static Stream<LocalUser?> watchUser() {
    return instance.localUsers
        .where()
        .watch(fireImmediately: true)
        .map((users) => users.firstOrNull);
  }

  /// Delete the user
  static Future<void> deleteUser() async {
    instance.write((isar) {
      isar.localUsers.clear();
    });
  }

  // ==================== SavingsGoal Methods ====================

  /// Add a savings goal
  static Future<void> addSavingsGoal(SavingsGoal goal) async {
    instance.write((isar) {
      isar.savingsGoals.put(goal);
    });
  }

  /// Add multiple savings goals
  static void addSavingsGoals(List<SavingsGoal> goals) {
    instance.write((isar) {
      isar.savingsGoals.putAll(goals);
    });
  }

  /// Update a savings goal
  static Future<void> updateSavingsGoal(SavingsGoal goal) async {
    instance.write((isar) {
      isar.savingsGoals.put(goal);
    });
  }

  /// Delete a savings goal by ID
  static Future<void> deleteSavingsGoal(String id) async {
    instance.write((isar) {
      isar.savingsGoals.delete(id);
    });
  }

  /// Get all savings goals
  static List<SavingsGoal> getAllSavingsGoals() {
    return instance.savingsGoals.where().findAll();
  }

  /// Get savings goal by ID
  static SavingsGoal? getSavingsGoalById(String id) {
    return instance.savingsGoals.get(id);
  }

  /// Watch all savings goals for changes
  static Stream<List<SavingsGoal>> watchSavingsGoals() {
    return instance.savingsGoals.where().watch(fireImmediately: true);
  }

  /// Get savings goal by period (year/month)
  static SavingsGoal? getSavingsGoalByPeriod(int year, int month) {
    return instance.savingsGoals
        .where()
        .yearEqualTo(year)
        .and()
        .monthEqualTo(month)
        .findFirst();
  }

  /// Clear all savings goals (for testing/debugging)
  static Future<void> clearSavingsGoals() async {
    instance.write((isar) {
      isar.savingsGoals.clear();
    });
  }

  // ==================== Envelope Methods ====================

  /// Add an envelope
  static Future<void> addEnvelope(Envelope envelope) async {
    instance.write((isar) {
      isar.envelopes.put(envelope);
    });
  }

  /// Add multiple envelopes
  static void addEnvelopes(List<Envelope> envelopes) {
    instance.write((isar) {
      isar.envelopes.putAll(envelopes);
    });
  }

  /// Update an envelope
  static Future<void> updateEnvelope(Envelope envelope) async {
    instance.write((isar) {
      isar.envelopes.put(envelope);
    });
  }

  /// Delete an envelope by ID
  static Future<void> deleteEnvelope(String id) async {
    instance.write((isar) {
      isar.envelopes.delete(id);
    });
  }

  /// Get all envelopes
  static List<Envelope> getAllEnvelopes() {
    return instance.envelopes.where().findAll();
  }

  /// Get envelope by ID
  static Envelope? getEnvelopeById(String id) {
    return instance.envelopes.get(id);
  }

  /// Watch all envelopes for changes
  static Stream<List<Envelope>> watchEnvelopes() {
    return instance.envelopes.where().watch(fireImmediately: true);
  }

  /// Clear all envelopes (for testing/debugging)
  static Future<void> clearEnvelopes() async {
    instance.write((isar) {
      isar.envelopes.clear();
    });
  }
}
