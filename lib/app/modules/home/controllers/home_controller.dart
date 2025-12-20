import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_user.dart'; // Added LocalUser import
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/ml/financial_intelligence.dart';
import 'package:koaa/app/services/ml/models/insight_generator.dart'; // Fixed Import

import 'package:koaa/app/services/changelog_service.dart';
import 'package:koaa/app/routes/app_pages.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'package:koaa/app/services/isar_service.dart';

import 'package:koaa/app/services/ml/smart_financial_brain.dart'; // Added valid import for SmartFinancialBrain
import 'package:logger/logger.dart';
import 'dart:math';
import 'dart:async'; // Fixed: Needed for Timer

// -----------------------------------------------------------------------------
// ENUMS
// -----------------------------------------------------------------------------

enum QuickActionType {
  goals,
  analytics,
  budget,
  debt,
  simulator,
  categories,
  settings,
  intelligence,
  challenges,
  envelopes,
}

// -----------------------------------------------------------------------------
// DTOs for Background Isolate Tasks
// -----------------------------------------------------------------------------

class JobGenerationInput {
  final List<Job> jobs;
  final List<LocalTransaction> allTransactions;
  final DateTime today;

  JobGenerationInput({
    required this.jobs,
    required this.allTransactions,
    required this.today,
  });
}

class RecurringGenerationInput {
  final List<RecurringTransaction> recurringTransactions;
  final List<LocalTransaction> allTransactions;
  final DateTime today;

  RecurringGenerationInput({
    required this.recurringTransactions,
    required this.allTransactions,
    required this.today,
  });
}

class RecurringGenerationResult {
  final List<LocalTransaction> newTransactions;
  final Map<String, DateTime> updatedLastGeneratedDates;

  RecurringGenerationResult({
    required this.newTransactions,
    required this.updatedLastGeneratedDates,
  });
}

// -----------------------------------------------------------------------------
// HomeController
// -----------------------------------------------------------------------------

class ContextualAction {
  final String label;
  final IconData icon;
  final TransactionCategory category;
  final String categoryId;

  ContextualAction({
    required this.label,
    required this.icon,
    required this.category,
    required this.categoryId,
  });
}

class HomeController extends GetxController {
  final Logger _logger = Logger();

  late final FinancialContextService _financialContextService;
  late final FinancialEventsService _financialEventsService;

  // UI State
  final RxList<LocalTransaction> transactions = <LocalTransaction>[].obs;
  final RxDouble balance = 0.0.obs;
  final RxDouble freeBalance = 0.0.obs; // New: Free to spend
  final RxBool balanceVisible = true.obs;
  final RxBool isCardFlipped = false.obs;
  final RxString userName = 'User'.obs;
  final Rx<LocalUser?> user = Rx<LocalUser?>(null);

  // Quick Actions & Sheet State
  final RxBool isMoreOptionsOpen = false.obs;
  final RxBool isSheetHidden = false.obs;
  final Rx<QuickActionType> thirdAction = QuickActionType.intelligence.obs;
  final RxList<QuickActionType> sheetActions = <QuickActionType>[].obs;
  final Rx<ContextualAction?> contextualAction =
      Rx<ContextualAction?>(null); // New Observable

  // Pagination
  int _transactionLimit = 50;
  bool _isLoadingMore = false;

  // ML & Insights
  final RxList<MLInsight> insights = <MLInsight>[].obs;
  final RxSet<String> readInsightIds = <String>{}.obs;

  // Workers
  final List<Worker> _workers = [];
  Timer? _debounceTimer;
  Timer? _contextualActionTimer; // New Timer

  @override
  void onInit() {
    super.onInit();

    // Robust service retrieval
    if (Get.isRegistered<FinancialContextService>()) {
      _financialContextService = Get.find<FinancialContextService>();
    } else {
      _logger
          .w('FinancialContextService not found in onInit. Waiting for it...');
      _financialContextService = Get.find<FinancialContextService>();
    }

    try {
      _financialEventsService = Get.find<FinancialEventsService>();
    } catch (e) {
      _logger.e('Failed to find FinancialEventsService: $e');
    }

    checkUser();
    _loadThirdAction();
    _loadSheetActions();

    // Load persisted balance visibility
    final settingsBox = Hive.box('settingsBox');
    balanceVisible.value =
        settingsBox.get('balanceVisible', defaultValue: true);
    isCardFlipped.value = settingsBox.get('isCardFlipped', defaultValue: false);

    // Load persisted read IDs
    final insightsBox = Hive.box('insightsBox');
    final savedReadIds = insightsBox.get('read_insight_ids');
    if (savedReadIds != null && savedReadIds is List) {
      readInsightIds.assignAll(savedReadIds.cast<String>());
    }

    // Load persisted insights (cache)
    final rawInsights = insightsBox.get('ml_insights');
    if (rawInsights != null && rawInsights is List) {
      try {
        final loaded = rawInsights
            .map((e) => MLInsight.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        // Filter expired on load
        final now = DateTime.now();
        final valid = loaded
            .where((i) => now.difference(i.createdAt).inHours < 72)
            .toList();

        // Apply read status from set
        for (var i in valid) {
          if (readInsightIds.contains(i.id)) {
            i.isRead = true;
          }
        }

        insights.assignAll(valid);
      } catch (e) {
        _logger.e('Failed to load insights: $e');
      }
    }

    // Listen to changes from FinancialContextService
    // Manual debounce implemented in the listener itself

    // Wait until FinancialContextService is initialized
    _workers
        .add(ever(_financialContextService.isInitialized, (bool initialized) {
      if (initialized) {
        _logger.i(
            'FinancialContextService initialized (via ever). Generating transactions.');
        _onServiceInitialized();
      }
    }));

    // Check immediately in case it's already initialized
    if (_financialContextService.isInitialized.value) {
      _logger.i(
          'FinancialContextService already initialized. Generating transactions.');
      _onServiceInitialized();
    }

    _workers.add(ever(_financialContextService.allTransactions, (_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _onTransactionsChanged();
      });
    }));

    // Show what's new popup if version changed (after 1s delay)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (Get.context != null) {
        ChangelogService.showWhatsNewIfNeeded(Get.context!);
      }
    });

    _workers.add(ever(
        _financialContextService.currentBalance, (_) => calculateBalance()));
    _workers.add(ever(_financialContextService.totalAllocatedBalance,
        (_) => calculateBalance())); // Listen to allocated changes

    // Initial load for transactions and balance if already initialized
    if (_financialContextService.isInitialized.value) {
      _onTransactionsChanged();
      calculateBalance();
      _updateInsights();
    }

    // Archive old transactions on startup
    archiveOldTransactions();

    // Start Contextual Action Timer (Every 30 minutes check is enough)
    _updateContextualAction();
    _contextualActionTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _updateContextualAction();
    });
  }

  void _updateContextualAction() {
    final now = DateTime.now();
    final hour = now.hour;

    ContextualAction? action;

    // Logic: Time-of-day suggestions
    if (hour >= 6 && hour < 11) {
      // Morning: Transport
      action = ContextualAction(
        label: 'Transport ?',
        icon: CupertinoIcons.bus,
        category: TransactionCategory.transport,
        categoryId: 'transport',
      );
    } else if (hour >= 11 && hour < 15) {
      // Lunch: Food
      action = ContextualAction(
        label: 'Déjeuner ?',
        icon: CupertinoIcons.cart, // or a food icon if available
        category: TransactionCategory.food,
        categoryId: 'food',
      );
    } else if (hour >= 18 && hour < 21) {
      // Evening: Groceries/Dinner
      action = ContextualAction(
        label: 'Courses ?',
        icon: CupertinoIcons.bag_fill,
        category: TransactionCategory.groceries,
        categoryId: 'groceries',
      );
    }

    // Only update if changed to avoid unnecessary rebuilds
    if (contextualAction.value?.label != action?.label) {
      contextualAction.value = action;
    }
  }

  void _onServiceInitialized() async {
    await generateJobIncomeTransactions();
    await generateRecurringTransactions();
  }

  void _onTransactionsChanged() {
    // Get all valid transactions from context
    var all = _financialContextService.allTransactions
        .where((t) => !t.isHidden)
        .toList();

    // Sort by date (newest first)
    all.sort((a, b) => b.date.compareTo(a.date));

    // Apply pagination limit
    final limited = all.take(_transactionLimit).toList();

    // Only update if different
    if (transactions.length != limited.length ||
        (transactions.isNotEmpty &&
            limited.isNotEmpty &&
            transactions.first.id != limited.first.id)) {
      transactions.assignAll(limited);
      calculateBalance();
      _updateInsights();
    } else if (transactions.isEmpty && limited.isNotEmpty) {
      transactions.assignAll(limited);
    }
  }

  void loadMoreTransactions() {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    // Increase limit
    _transactionLimit += 50;
    _onTransactionsChanged();

    // Reset flag after a small delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoadingMore = false;
    });
  }

  void _updateInsights() {
    if (Get.isRegistered<SmartFinancialBrain>()) {
      try {
        final brain = Get.find<SmartFinancialBrain>();
        final intelligence = brain.intelligence.value;

        final newInsights = <MLInsight>[];

        // 1. Map Spending Alerts (High Priority)
        if (intelligence.spendingAlerts.isNotEmpty) {
          final alertInsights = intelligence.spendingAlerts.map((alert) {
            final stableId =
                'alert_${alert.categoryId}_${DateTime.now().day}'; // Daily alert stability

            // Map severity to priority
            int priority = 5;
            switch (alert.severity) {
              case AlertSeverity.critical:
                priority = 10;
                break;
              case AlertSeverity.high:
                priority = 9;
                break;
              case AlertSeverity.medium:
                priority = 7;
                break;
              case AlertSeverity.low:
                priority = 5;
                break;
            }

            return MLInsight(
              id: stableId,
              title: 'Alerte Dépense',
              description: alert.message,
              type: InsightType.warning,
              priority: priority,
              actionRoute: Routes.budget, // Corrected route case
              actionLabel: 'Voir Budget',
              isRead: readInsightIds.contains(stableId),
            );
          });
          newInsights.addAll(alertInsights);
        }

        // 2. Map Recommendations (Standard Priority)
        if (intelligence.recommendations.isNotEmpty) {
          final recInsights = intelligence.recommendations.take(5).map((rec) {
            // Use Title Hash for ID stability (Priority can fluctuate)
            final stableId = 'rec_${rec.category.index}_${rec.title.hashCode}';
            return MLInsight(
              id: stableId,
              title: rec.title,
              description: rec.description,
              type: _mapRecTypeToInsightType(rec.category),
              priority: _mapRecPriorityToInt(rec.priority),
              actionRoute: rec.actionRoute,
              actionLabel: rec.actionLabel,
              isRead: readInsightIds.contains(stableId),
            );
          });
          newInsights.addAll(recInsights);
        }

        // 3. Sort by priority and assign
        newInsights.sort((a, b) => b.priority.compareTo(a.priority));

        if (newInsights.isNotEmpty) {
          insights.assignAll(newInsights);

          final box = Hive.box('insightsBox');
          final jsonList = insights.map((e) => e.toJson()).toList();
          box.put('ml_insights', jsonList);
        }
      } catch (e) {
        _logger.e('Error updating insights', error: e);
      }
    }
  }

  void markInsightsAsRead() {
    bool changed = false;
    for (var i in insights) {
      if (!readInsightIds.contains(i.id)) {
        readInsightIds.add(i.id); // Add to persistent set
        i.isRead = true;
        changed = true;
      }
    }

    if (changed) {
      insights.refresh();
      final box = Hive.box('insightsBox');

      // Save Read IDs
      box.put('read_insight_ids', readInsightIds.toList());

      // Save Insights (with updated read status)
      final jsonList = insights.map((e) => e.toJson()).toList();
      box.put('ml_insights', jsonList);
    }
  }

  // Insight Helpers
  InsightType _mapRecTypeToInsightType(RecommendationCategory cat) {
    switch (cat) {
      case RecommendationCategory.spending:
        return InsightType.warning; // Mapped to closest type
      case RecommendationCategory.savings:
        return InsightType.tip;
      case RecommendationCategory.budget:
        return InsightType.warning;
      case RecommendationCategory.debt:
        return InsightType.info;
      default:
        return InsightType.info;
    }
  }

  int _mapRecPriorityToInt(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 10;
      case RecommendationPriority.high:
        return 8;
      case RecommendationPriority.medium:
        return 5;
      case RecommendationPriority.low:
        return 3;
    }
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    _debounceTimer?.cancel();
    _contextualActionTimer?.cancel();
    super.onClose();
  }

  void checkUser() {
    try {
      final userBox = Hive.box<LocalUser>('userBox');
      final settingsBox = Hive.box('settingsBox');

      final hasUser = userBox.isNotEmpty;
      // Also check settingsBox for legacy flags if needed, but userBox presence is definitive source of truth now
      // settingsBox.get('hasUser', defaultValue: false);

      if (hasUser) {
        final currentUser = userBox.values.first;
        user.value = currentUser;
        userName.value = currentUser.fullName;
      } else {
        userName.value = 'User';
      }

      // Sync legacy flag just in case
      if (settingsBox.get('hasUser') != hasUser) {
        settingsBox.put('hasUser', hasUser);
      }
    } catch (e) {
      _logger.e('Failed to load user: $e');
    }
  }

  // Proper getter for home_view
  int get displayedTransactionCount => transactions.length;

  // Catch-up transactions logic
  Future<void> addCatchUpTransactions(Map<String, double> spending) async {
    final now = DateTime.now();
    final catchUpDate =
        now.subtract(const Duration(hours: 1)); // Just before now

    final newTransactions = <LocalTransaction>[];

    spending.forEach((categoryId, amount) {
      if (amount > 0) {
        // Find category enum from ID or string
        final category = TransactionCategory.values.firstWhere(
          (e) => e.name == categoryId,
          orElse: () => TransactionCategory.otherExpense, // Fixed: Correct enum
        );

        newTransactions.add(LocalTransaction.create(
          amount: amount,
          description: 'Rattrapage: ${category.name}',
          date: catchUpDate,
          type: TransactionType.expense,
          category: category,
          categoryId: categoryId,
        ));
      }
    });

    if (newTransactions.isNotEmpty) {
      IsarService.addTransactions(newTransactions); // Fixed: Removed await
      _logger.i('Added ${newTransactions.length} catch-up transactions');
      // Trigger refresh
      _onTransactionsChanged();
    }
  }

  void calculateBalance() {
    if (_financialContextService.isInitialized.value) {
      balance.value = _financialContextService.currentBalance.value;
      freeBalance.value = _financialContextService.freeBalance;
    }
  }

  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
    final settingsBox = Hive.box('settingsBox');
    settingsBox.put('balanceVisible', balanceVisible.value);
  }

  void toggleCardFlip() {
    isCardFlipped.value = !isCardFlipped.value;
    final settingsBox = Hive.box('settingsBox');
    settingsBox.put('isCardFlipped', isCardFlipped.value);
  }

  // --- Quick Action & Sheet Logic ---

  void _loadThirdAction() {
    final settingsBox = Hive.box('settingsBox');
    final savedAction = settingsBox.get('thirdAction',
        defaultValue: QuickActionType.intelligence.toString());

    try {
      thirdAction.value = QuickActionType.values.firstWhere(
          (e) => e.toString() == savedAction,
          orElse: () => QuickActionType.intelligence);
    } catch (_) {
      thirdAction.value = QuickActionType.intelligence;
    }
  }

  void setThirdAction(QuickActionType action) {
    thirdAction.value = action;
    final settingsBox = Hive.box('settingsBox');
    settingsBox.put('thirdAction', action.toString());
  }

  void _loadSheetActions() {
    final settingsBox = Hive.box('settingsBox');
    final savedActions = settingsBox.get('sheetActions');

    // Build initial list from saved order or default
    List<QuickActionType> orderedActions;

    if (savedActions != null && savedActions is List) {
      orderedActions = <QuickActionType>[];
      for (var s in savedActions) {
        try {
          final action =
              QuickActionType.values.firstWhere((e) => e.toString() == s);
          // Only add if not already in list and not the thirdAction
          if (!orderedActions.contains(action)) {
            orderedActions.add(action);
          }
        } catch (_) {}
      }
    } else {
      orderedActions = QuickActionType.values.toList();
    }

    // ALWAYS ensure all actions are present (except thirdAction)
    // This handles new actions added after initial save
    for (var action in QuickActionType.values) {
      if (!orderedActions.contains(action)) {
        orderedActions.add(action);
      }
    }

    // ALWAYS remove the current thirdAction from the sheet list
    orderedActions.remove(thirdAction.value);

    sheetActions.assignAll(orderedActions);
    _saveSheetActions();

    // React to thirdAction changes
    ever(thirdAction, (QuickActionType newAction) {
      // Get the old thirdAction (it's already removed, need to add it back)
      // Start fresh: all actions in current order, minus new third
      final updated = <QuickActionType>[];

      // First, add all from current sheetActions (preserves user order)
      for (var a in sheetActions) {
        if (a != newAction) {
          updated.add(a);
        }
      }

      // Add any missing actions (like the old thirdAction which wasn't in sheetActions)
      for (var action in QuickActionType.values) {
        if (action != newAction && !updated.contains(action)) {
          updated.add(action);
        }
      }

      sheetActions.assignAll(updated);
      _saveSheetActions();
    });
  }

  void reorderSheetAction(QuickActionType data, QuickActionType target) {
    final currentIndex = sheetActions.indexOf(data);
    final targetIndex = sheetActions.indexOf(target);

    if (currentIndex != -1 && targetIndex != -1) {
      sheetActions.removeAt(currentIndex);
      sheetActions.insert(targetIndex, data);
      _saveSheetActions();
    }
  }

  void _saveSheetActions() {
    final settingsBox = Hive.box('settingsBox');
    final strings = sheetActions.map((e) => e.toString()).toList();
    settingsBox.put('sheetActions', strings);
  }

  Future<void> addTransaction(LocalTransaction transaction) async {
    try {
      IsarService.addTransaction(transaction);
      _financialEventsService.emitTransactionAdded(transaction);
    } catch (e) {
      _logger.e('Error adding transaction: $e');
      Get.snackbar('Erreur', 'Impossible d\'ajouter la transaction');
    }
  }

  // ---------------------------------------------------------------------------
  // OPTIMIZED GENERATION LOGIC (JOB INCOME)
  // ---------------------------------------------------------------------------

  Future<void> generateJobIncomeTransactions() async {
    final jobBox =
        Hive.box<Job>('jobBox'); // Fixed: name mismatch (was jobsBox)
    if (jobBox.isEmpty) return;

    final jobs = jobBox.values.toList();
    final today = DateTime.now();

    try {
      final allTransactions = await IsarService.getAllTransactions();

      // Detach jobs from Hive box before sending to isolate
      final detachedJobs = jobs
          .map((j) => Job(
                id: j.id,
                name: j.name,
                amount: j.amount,
                frequency: j.frequency,
                paymentDate: j.paymentDate,
                isActive: j.isActive,
                createdAt: j.createdAt,
                endDate: j.endDate,
              ))
          .toList();

      final input = JobGenerationInput(
        jobs: detachedJobs,
        allTransactions: allTransactions,
        today: today,
      );

      final newTransactions = await compute(_runJobGeneration, input);

      if (newTransactions.isNotEmpty) {
        _logger.i('Generated ${newTransactions.length} new job transactions');
        if (newTransactions.length > 1) {
          IsarService.addTransactions(newTransactions);
        } else {
          addTransaction(newTransactions.first);
        }
      }
    } catch (e, st) {
      _logger.e('Error generating job transactions', error: e, stackTrace: st);
    }
  }

  static List<LocalTransaction> _runJobGeneration(JobGenerationInput input) {
    final newTransactions = <LocalTransaction>[];
    final existingJobTransactions = <String>{};

    for (var tx in input.allTransactions) {
      if (tx.linkedJobId != null) {
        final dateKey = '${tx.date.year}-${tx.date.month}';
        existingJobTransactions.add('${tx.linkedJobId}-$dateKey');
      }
    }

    for (var job in input.jobs) {
      if (!job.isActive) continue;
      if (job.endDate != null && job.endDate!.isBefore(input.today)) {
        continue;
      }

      // Check if payment is due today or past due for this month
      // logic similar to Job.isPaymentDue but handling the specific 'generate' requirement
      // We want to generate ONE transaction for this month if it's due.

      // Simplified Logic for "Monthly Salary" Generation:
      // We assume jobs pay monthly for now in this generator logic,
      // or we check if a payment is due this month.

      // For accurate frequency support:
      // We need to know if a transaction is missing for the CURRENT due date.

      // Let's rely on job.paymentDate day component for monthly jobs as primary use case.
      // (Advanced frequency support would require more complex checking against history).

      final payday =
          DateTime(input.today.year, input.today.month, job.paymentDate.day);

      if (input.today.isAfter(payday) || input.today.isAtSameMomentAs(payday)) {
        final identifier = '${job.id}-${input.today.year}-${input.today.month}';

        if (!existingJobTransactions.contains(identifier)) {
          final transaction = LocalTransaction.create(
            amount: job.monthlyIncome,
            description: 'Salaire: ${job.name}', // Fixed: job.name
            date: payday,
            type: TransactionType.income,
            category: TransactionCategory.salary,
            categoryId: 'salary',
            linkedJobId: job.id,
            isRecurring: true,
          );
          newTransactions.add(transaction);
        }
      }
    }
    return newTransactions;
  }

  // ---------------------------------------------------------------------------
  // OPTIMIZED GENERATION LOGIC (RECURRING TRANSACTIONS)
  // ---------------------------------------------------------------------------

  Future<void> generateRecurringTransactions() async {
    final recurringBox =
        Hive.box<RecurringTransaction>('recurringTransactionBox');
    if (recurringBox.isEmpty) return;

    final recurringTransactions = recurringBox.values.toList();
    final today = DateTime.now();

    try {
      final allTransactions = await IsarService.getAllTransactions();

      // Detach recurring transactions from Hive box before sending to isolate
      final detachedRecurring = recurringTransactions
          .map((r) => RecurringTransaction(
                id: r.id,
                amount: r.amount,
                description: r.description,
                frequency: r.frequency,
                daysOfWeek: List<int>.from(r.daysOfWeek),
                dayOfMonth: r.dayOfMonth,
                lastGeneratedDate: r.lastGeneratedDate,
                category: r.category,
                type: r.type,
                categoryId: r.categoryId,
                endDate: r.endDate,
                isActive: r.isActive,
                createdAt: r.createdAt,
              ))
          .toList();

      final input = RecurringGenerationInput(
        recurringTransactions: detachedRecurring,
        allTransactions: allTransactions,
        today: today,
      );

      final result = await compute(_runRecurringGeneration, input);

      if (result.newTransactions.isNotEmpty) {
        _logger.i(
            'Generated ${result.newTransactions.length} recurring transactions');
        IsarService.addTransactions(result.newTransactions);
      }

      if (result.updatedLastGeneratedDates.isNotEmpty) {
        for (var entry in result.updatedLastGeneratedDates.entries) {
          final id = entry.key;
          final newDate = entry.value;
          final recurring = recurringBox.get(id);
          if (recurring != null) {
            recurring.lastGeneratedDate = newDate;
            recurring.save();
          }
        }
        _logger.i(
            'Updated ${result.updatedLastGeneratedDates.length} recurring schedules');
      }
    } catch (e, st) {
      _logger.e('Error generating recurring transactions',
          error: e, stackTrace: st);
    }
  }

  static RecurringGenerationResult _runRecurringGeneration(
      RecurringGenerationInput input) {
    final newTransactions = <LocalTransaction>[];
    final updatedDates = <String, DateTime>{};
    final existingRecurringTransactions = <String>{};

    for (var tx in input.allTransactions) {
      if (tx.linkedRecurringId != null) {
        final dateKey = '${tx.date.year}-${tx.date.month}-${tx.date.day}';
        existingRecurringTransactions.add('${tx.linkedRecurringId}-$dateKey');
      }
    }

    for (var recurring in input.recurringTransactions) {
      final dueDates = _calculateDueDates(recurring, input.today);
      DateTime? lastGenerated = recurring.lastGeneratedDate;

      for (var dueDate in dueDates) {
        final identifier =
            '${recurring.id}-${dueDate.year}-${dueDate.month}-${dueDate.day}';

        if (!existingRecurringTransactions.contains(identifier)) {
          final transaction = LocalTransaction.create(
            amount: recurring.amount,
            description: recurring.description,
            date: dueDate,
            type: recurring.type,
            category: recurring.category,
            categoryId: recurring.categoryId,
            linkedRecurringId: recurring.id,
            isRecurring: true,
          );

          newTransactions.add(transaction);

          if (lastGenerated == null || dueDate.isAfter(lastGenerated)) {
            lastGenerated = dueDate;
          }
        }
      }

      if (lastGenerated != null &&
          lastGenerated != recurring.lastGeneratedDate) {
        updatedDates[recurring.id] = lastGenerated;
      }
    }

    return RecurringGenerationResult(
      newTransactions: newTransactions,
      updatedLastGeneratedDates: updatedDates,
    );
  }

  static List<DateTime> _calculateDueDates(
      RecurringTransaction recurring, DateTime today) {
    final dueDates = <DateTime>[];
    final endDate = recurring.endDate ?? today.add(const Duration(days: 365));

    switch (recurring.frequency) {
      case Frequency.daily:
        var current = recurring.lastGeneratedDate.add(const Duration(days: 1));
        while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
          if (current.isAfter(endDate)) break;
          dueDates.add(current);
          current = current.add(const Duration(days: 1));
        }
        break;

      case Frequency.weekly:
        var current = recurring.lastGeneratedDate.add(const Duration(days: 7));
        while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
          if (current.isAfter(endDate)) break;
          dueDates.add(current);
          current = current.add(const Duration(days: 7));
        }
        break;

      case Frequency.biWeekly:
        var current = recurring.lastGeneratedDate.add(const Duration(days: 14));
        while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
          if (current.isAfter(endDate)) break;
          dueDates.add(current);
          current = current.add(const Duration(days: 14));
        }
        break;

      case Frequency.monthly:
        var targetMonth = DateTime(recurring.lastGeneratedDate.year,
            recurring.lastGeneratedDate.month + 1);

        while (targetMonth.isBefore(today) ||
            targetMonth.isAtSameMomentAs(today)) {
          final anchorDay = recurring.startDate.day;
          final maxDays =
              DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
          final targetDay = min(anchorDay, maxDays);

          final current =
              DateTime(targetMonth.year, targetMonth.month, targetDay);

          if (current.isAfter(endDate)) break;

          if (current.isAfter(recurring.lastGeneratedDate)) {
            dueDates.add(current);
          }

          targetMonth = DateTime(targetMonth.year, targetMonth.month + 1);
        }
        break;

      case Frequency.yearly:
        var current = DateTime(recurring.lastGeneratedDate.year + 1,
            recurring.lastGeneratedDate.month, recurring.lastGeneratedDate.day);

        while (current.isBefore(today) || current.isAtSameMomentAs(today)) {
          if (current.isAfter(endDate)) break;
          dueDates.add(current);
          current = DateTime(current.year + 1, current.month, current.day);
        }
        break;
    }

    return dueDates;
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  LocalTransaction? get lastTransaction =>
      transactions.isNotEmpty ? transactions.first : null;

  MapEntry<TransactionCategory, double>? get topSpendingCategory {
    if (transactions.isEmpty) return null;
    final stats = <TransactionCategory, double>{};
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        stats[t.category] = (stats[t.category] ?? 0) + t.amount;
      }
    }
    if (stats.isEmpty) return null;
    return stats.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  List<double> get recentActivityData {
    final now = DateTime.now();
    final data = List.filled(7, 0.0);
    for (var t in transactions) {
      final diff = now.difference(t.date).inDays;
      if (diff >= 0 && diff < 7) {
        if (t.type == TransactionType.expense) {
          data[6 - diff] += t.amount;
        }
      }
    }
    return data;
  }

  String get formattedBalance {
    final format = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
    return format.format(balance.value);
  }

  Color getTimeOfDayColor() {
    final h = DateTime.now().hour;
    if (h < 12) return const Color(0xFF2D3250);
    if (h < 17) return const Color(0xFF1E3A5F);
    if (h < 21) return const Color(0xFF2C1810);
    return const Color(0xFF0F0F1E);
  }

  LinearGradient getTimeOfDayGradient() {
    final h = DateTime.now().hour;
    if (h < 12) {
      return LinearGradient(
          colors: [const Color(0xFF2D3250), const Color(0xFF424769)]);
    }
    if (h < 17) {
      return LinearGradient(
          colors: [const Color(0xFF1E3A5F), const Color(0xFF2E5984)]);
    }
    if (h < 21) {
      return LinearGradient(
          colors: [const Color(0xFF2C1810), const Color(0xFF4A2C1A)]);
    }
    return LinearGradient(
        colors: [const Color(0xFF0F0F1E), const Color(0xFF1A1B2E)]);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  void openDrawer() => scaffoldKey.currentState?.openDrawer();
  void closeDrawer() => scaffoldKey.currentState?.closeDrawer();

  Future<void> archiveOldTransactions() async {
    try {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
      final allTransactions = await IsarService.getAllTransactions();
      int archivedCount = 0;

      for (var transaction in allTransactions) {
        if (!transaction.isHidden && transaction.date.isBefore(oneYearAgo)) {
          transaction.isHidden = true;
          IsarService.updateTransaction(transaction);
          archivedCount++;
        }
      }

      if (archivedCount > 0) {
        _logger.i('Archived $archivedCount old transactions');
        _onTransactionsChanged();
      }
    } catch (e, st) {
      _logger.e('Failed to archive old transactions', stackTrace: st);
    }
  }
}
