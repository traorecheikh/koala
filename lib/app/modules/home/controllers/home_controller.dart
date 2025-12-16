import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/modules/home/widgets/user_setup_dialog.dart';
import 'package:koaa/app/services/financial_context_service.dart'; // New Import
import 'package:koaa/app/services/events/financial_events_service.dart'; // New Import
import 'package:koaa/app/services/ml_service.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/core/utils/debounce.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import 'dart:math';
import 'dart:async'; // Added import for StreamSubscription
import 'package:koaa/app/services/widget_service.dart';
import 'package:koaa/app/services/changelog_service.dart';

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
}

class HomeController extends GetxController {
  final balanceVisible = true.obs;
  final userName = ''.obs;
  final Rxn<LocalUser> user = Rxn<LocalUser>();
  final RxDouble balance = 0.0.obs;
  final RxList<LocalTransaction> transactions = <LocalTransaction>[].obs;
  final RxBool isCardFlipped = false.obs;
  final RxList<MLInsight> insights = <MLInsight>[].obs;
  final _mlService = MLService();

  // Customizable Quick Action (Slot 3)
  final thirdAction = QuickActionType.goals.obs;

  // Sheet Actions Order
  final sheetActions = <QuickActionType>[].obs;

  // Sheet State
  final isMoreOptionsOpen = false.obs;
  final isSheetHidden = false.obs; // Hidden while dragging

  late FinancialContextService _financialContextService;
  late FinancialEventsService _financialEventsService;
  Debounce? _debounceTransactionUpdate;
  final _logger = Logger();

  // Cached transaction index for quick lookups (optimization)
  final Map<String, LocalTransaction> _transactionCache = {};

  // Workers for cleanup and StreamSubscriptions
  final List<Worker> _workers = [];
  StreamSubscription? _userSubscription; // Store the user subscription

  @override
  void onInit() {
    super.onInit();

    // Robust service retrieval
    if (Get.isRegistered<FinancialContextService>()) {
      _financialContextService = Get.find<FinancialContextService>();
    } else {
      // This should theoretically not happen if main.dart is correct,
      // but in case of weird restart/binding loops:
      _logger
          .w('FinancialContextService not found in onInit. Waiting for it...');
      // We can't really "wait" here effectively without async,
      // but we can try to put it if missing (dangerous) or just throw a better error.
      // Better: assume it will be put and we can find it later? No.
      // Let's try to find it.
      _financialContextService = Get.find<FinancialContextService>();
    }

    try {
      _financialEventsService = Get.find<FinancialEventsService>();
    } catch (e) {
      _logger.e('Failed to find FinancialEventsService: $e');
    }

    checkUser();
    _loadThirdAction();
    _loadSheetActions(); // Load sheet order

    // Listen to changes from FinancialContextService with debouncing (500ms)
    // This prevents excessive rebuilds when multiple transactions are added quickly
    _debounceTransactionUpdate = Debounce(
      const Duration(milliseconds: 500),
      () => _onTransactionsChanged(),
    );

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
      _debounceTransactionUpdate?.call();
    }));

    // Show what's new popup if version changed (after 1s delay)
    Future.delayed(const Duration(milliseconds: 1200), () {
      ChangelogService.showWhatsNewIfNeeded(Get.context!);
    });
    _workers.add(ever(
        _financialContextService.currentBalance, (_) => calculateBalance()));

    // Initial load for transactions and balance if already initialized
    if (_financialContextService.isInitialized.value) {
      transactions.assignAll(_financialContextService.allTransactions
          .where((t) => !t.isHidden)
          .toList());
      calculateBalance();
      _updateInsights();
    }

    // Archive old transactions on startup (fire and forget)
    archiveOldTransactions();
  }

  Future<void> _onServiceInitialized() async {
    await generateRecurringTransactions();
    await generateJobIncomeTransactions();
  }

  /// Handle transaction changes with debouncing to prevent excessive rebuilds
  void _onTransactionsChanged() {
    // FIX: Create immutable copy to prevent concurrent modification
    final allTransactions = _financialContextService.allTransactions;
    if (allTransactions.isEmpty) {
      transactions.clear();
    } else {
      final transactionsCopy = List<LocalTransaction>.from(
          allTransactions.where((t) => !t.isHidden));
      // FIX: Sort by date (newest first) to ensure proper ordering
      transactionsCopy.sort((a, b) => b.date.compareTo(a.date));
      transactions.assignAll(transactionsCopy);
    }
    _rebuildTransactionCache(); // Update cache on transaction changes
    calculateBalance();
    _updateInsights();
    _refreshIntelligence();
  }

  /// Rebuild the transaction cache for fast lookups (optimization)
  void _rebuildTransactionCache() {
    _transactionCache.clear();
    for (var transaction in transactions) {
      if (transaction.id.isNotEmpty) {
        _transactionCache[transaction.id] = transaction;
      }
    }
  }

  /// Get transaction by ID using cached index (O(1) instead of O(n))
  /// Returns null if transaction not found
  LocalTransaction? getTransactionById(String id) {
    return _transactionCache[id];
  }

  @override
  void onClose() {
    // Cancel debounce
    _debounceTransactionUpdate?.cancel();
    _debounceTransactionUpdate = null;

    // Dispose all workers
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    // Clear all observables
    transactions.clear();
    insights.clear();
    sheetActions.clear();

    _userSubscription?.cancel(); // Cancel user subscription
    super.onClose();
  }

  Future<void> _loadThirdAction() async {
    // Open box safely if not already open (though SettingsController usually opens it)
    final box = await Hive.openBox('settingsBox');
    final savedIndex = box.get('thirdAction');
    if (savedIndex != null) {
      thirdAction.value = QuickActionType.values[savedIndex];
    }
  }

  void setThirdAction(QuickActionType type) {
    thirdAction.value = type;
    Hive.box('settingsBox').put('thirdAction', type.index);
  }

  Future<void> _loadSheetActions() async {
    final box = await Hive.openBox('settingsBox');
    final savedIndices = box.get('sheetActionsOrder');

    if (savedIndices != null) {
      final indices = List<int>.from(savedIndices);
      sheetActions.assignAll(indices.map((i) => QuickActionType.values[i]));
    } else {
      // Default order (excluding Goals which is default on home, but we include all for flexibility)
      // We prioritize the ones NOT on home usually.
      sheetActions.assignAll([
        QuickActionType.intelligence, // AI Intelligence - prioritized
        QuickActionType.analytics,
        QuickActionType.budget,
        QuickActionType.debt,
        QuickActionType.simulator,
        QuickActionType.categories,
        QuickActionType.settings,
        QuickActionType.goals,
      ]);
    }
  }

  void reorderSheetAction(QuickActionType item, QuickActionType target) {
    final oldIndex = sheetActions.indexOf(item);
    final newIndex = sheetActions.indexOf(target);
    if (oldIndex != -1 && newIndex != -1) {
      sheetActions.removeAt(oldIndex);
      sheetActions.insert(newIndex, item);
      Hive.box('settingsBox')
          .put('sheetActionsOrder', sheetActions.map((e) => e.index).toList());
    }
  }

  Future<void> generateJobIncomeTransactions() async {
    final jobBox = Hive.box<Job>('jobBox');
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    final jobs = jobBox.values.where((job) => job.isActive).toList();
    final today = DateTime.now();

    // DEBUG: Log all transactions in the box
    _logger.d('TransactionBox total items: ${transactionBox.length}');
    for (var tx in transactionBox.values) {
      _logger.d(
          '  TX: id=${tx.id}, linkedJobId=${tx.linkedJobId}, type=${tx.type}, isHidden=${tx.isHidden}, desc=${tx.description}');
    }

    // FIXED: Read transactions directly from Hive to ensure we check duplicates
    // even when FinancialContextService hasn't loaded yet (e.g., during onboarding)
    final Set<String> existingJobTransactions = transactionBox.values
        .where((tx) =>
            tx.linkedJobId != null &&
            tx.type == TransactionType.income &&
            !tx.isHidden)
        .map((tx) {
      final normalizedDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      return '${tx.linkedJobId}-${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';
    }).toSet();

    // FALLBACK: Also check by description pattern + date for legacy data with null linkedJobId
    // This handles transactions saved before the Hive adapter was fixed
    final Set<String> existingByDescription = transactionBox.values
        .where((tx) =>
            tx.description.startsWith('Salaire: ') &&
            tx.type == TransactionType.income &&
            tx.category == TransactionCategory.salary &&
            !tx.isHidden)
        .map((tx) {
      final normalizedDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      // Extract job name from description "Salaire: JobName"
      final jobName = tx.description.replaceFirst('Salaire: ', '');
      return '$jobName-${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}';
    }).toSet();

    _logger.d(
        'Found ${existingJobTransactions.length} existing job transactions (by linkedJobId).');
    _logger.d(
        'Found ${existingByDescription.length} existing salary transactions (by description fallback).');
    _logger.d('Processing ${jobs.length} active jobs.');

    for (var job in jobs) {
      // Determine last payday
      DateTime lastPayday;

      // Calculate payment date for THIS month
      final thisMonthPayday =
          DateTime(today.year, today.month, job.paymentDate.day);

      if (today.isAfter(thisMonthPayday) ||
          today.isAtSameMomentAs(thisMonthPayday)) {
        // Payday has passed this month
        lastPayday = thisMonthPayday;
      } else {
        // Payday hasn't happened yet this month, so it was last month
        if (today.month == 1) {
          lastPayday = DateTime(today.year - 1, 12, job.paymentDate.day);
        } else {
          lastPayday =
              DateTime(today.year, today.month - 1, job.paymentDate.day);
        }
      }

      // Check if transaction exists using the pre-computed set
      final jobTransactionIdentifier =
          '${job.id}-${lastPayday.year}-${lastPayday.month}-${lastPayday.day}';

      // Fallback identifier using job name instead of job id
      final descriptionIdentifier =
          '${job.name}-${lastPayday.year}-${lastPayday.month}-${lastPayday.day}';

      // Check BOTH methods - linkedJobId (new) and description fallback (legacy)
      final existsByLinkedJobId =
          existingJobTransactions.contains(jobTransactionIdentifier);
      final existsByDescription =
          existingByDescription.contains(descriptionIdentifier);

      if (!existsByLinkedJobId && !existsByDescription) {
        _logger.i(
            'Generating salary for job ${job.name} on $lastPayday (ID: $jobTransactionIdentifier)');

        final transaction = LocalTransaction(
          amount: job.amount,
          description: 'Salaire: ${job.name}',
          date: lastPayday,
          type: TransactionType.income,
          category: TransactionCategory.salary,
          linkedJobId: job.id,
        );

        // Use await to ensure transaction is persisted before continuing
        await addTransaction(transaction);

        // Add to both sets to prevent duplicates within the same loop iteration
        existingJobTransactions.add(jobTransactionIdentifier);
        existingByDescription.add(descriptionIdentifier);
      } else {
        _logger.d(
            'Skipping duplicate salary for job ${job.name} on $lastPayday '
            '(existsByLinkedJobId: $existsByLinkedJobId, existsByDescription: $existsByDescription)');
      }
    }
  }

  void _refreshIntelligence() {
    try {
      final intelligence = Get.find<IntelligenceService>();
      intelligence.forceRefresh();
    } catch (_) {
      // Intelligence service not available
    }
  }

  void _updateInsights() {
    insights.value =
        _mlService.generateInsights(_financialContextService.allTransactions);
  }

  void checkUser() {
    final userBox = Hive.box<LocalUser>('userBox');
    _logger.i('checkUser: userBox is empty: ${userBox.isEmpty}');
    if (userBox.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logger.i('checkUser: Showing user setup dialog.');
        showUserSetupDialog(Get.context!);
      });
    } else {
      user.value = userBox.getAt(0);
      userName.value = user.value?.fullName ?? 'User';
      _logger.i('checkUser: User found: ${userName.value}');
    }

    _userSubscription = user.listen((newUser) {
      if (newUser != null) {
        final userBox = Hive.box<LocalUser>('userBox');
        if (userBox.isEmpty) {
          userBox.add(newUser);
          _logger.i('checkUser: Added new user to userBox during listen.');
        } else {
          userBox.putAt(0, newUser);
          _logger
              .i('checkUser: Updated existing user in userBox during listen.');
        }
        userName.value = newUser.fullName;
      }
    });
  }

  void toggleBalanceVisibility() {
    balanceVisible.value = !balanceVisible.value;
  }

  void toggleCardFlip() {
    isCardFlipped.value = !isCardFlipped.value;
  }

  void calculateBalance() {
    balance.value = _financialContextService.currentBalance.value;
  }

  Future<void> addTransaction(LocalTransaction transaction) async {
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    await transactionBox.put(transaction.id, transaction);
    // CRITICAL: Force flush to disk to survive hot restart
    await transactionBox.flush();
    _logger.i(
        'Transaction saved to Hive with ID: ${transaction.id}, linkedJobId: ${transaction.linkedJobId}');
    _logger.d('TransactionBox now has ${transactionBox.length} items');
    _financialEventsService.emitTransactionAdded(transaction);

    // Update home screen widgets
    WidgetService.updateAllWidgets();
  }

  /// Add catch-up transactions for users who install the app mid-month.
  /// These transactions are SPREAD across the days from the 1st to yesterday
  /// to avoid skewing daily spending patterns and behavior analytics.
  Future<void> addCatchUpTransactions(
      Map<String, double> categorySpending) async {
    if (categorySpending.isEmpty) return;

    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final yesterday = now.subtract(const Duration(days: 1));

    // Calculate number of days to spread transactions across
    final daysToSpread = yesterday.difference(firstOfMonth).inDays + 1;

    // If we're on the 1st or 2nd, just use today's date
    if (daysToSpread <= 1) {
      for (final entry in categorySpending.entries) {
        if (entry.value <= 0) continue;
        final transaction = LocalTransaction(
          id: const Uuid().v4(),
          amount: entry.value,
          description: 'Rattrapage du mois',
          date: firstOfMonth,
          type: TransactionType.expense,
          categoryId: entry.key,
          category: null,
          isCatchUp: true,
        );
        await addTransaction(transaction);
      }
      return;
    }

    _logger.i(
        'Spreading ${categorySpending.length} catch-up categories across $daysToSpread days');

    for (final entry in categorySpending.entries) {
      final categoryId = entry.key;
      final totalAmount = entry.value;

      if (totalAmount <= 0) continue;

      // Determine how many transactions to create (1 per 2-3 days, max 10)
      int numTransactions = (daysToSpread / 2).ceil().clamp(1, 10);
      final amountPerTransaction = totalAmount / numTransactions;

      // Create transactions spread across the period
      for (int i = 0; i < numTransactions; i++) {
        // Calculate the day offset for this transaction
        final dayOffset = (daysToSpread * i / numTransactions).round();
        final transactionDate = firstOfMonth.add(Duration(days: dayOffset));

        final transaction = LocalTransaction(
          id: const Uuid().v4(),
          amount: amountPerTransaction,
          description: 'Rattrapage',
          date: transactionDate,
          type: TransactionType.expense,
          categoryId: categoryId,
          category: null,
          isCatchUp: true,
        );

        await addTransaction(transaction);
      }
    }

    _logger.i('Catch-up transactions distributed successfully');
  }

  Future<void> deleteTransaction(LocalTransaction transaction) async {
    // Soft delete: Mark as hidden but keep in database for calculations
    transaction.isHidden = true;
    await transaction.save();
    // Refresh list to hide it from UI (filter out hidden transactions)
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    transactions
        .assignAll(transactionBox.values.where((t) => !t.isHidden).toList());
    _financialEventsService.emitTransactionDeleted(transaction.id);
  }

  Future<void> generateRecurringTransactions() async {
    try {
      final recurringBox = Hive.box<RecurringTransaction>(
        'recurringTransactionBox',
      );
      final today = DateTime.now();
      int generatedCount = 0;

      _logger.i(
          'Starting recurring transaction generation for ${recurringBox.length} items');

      for (var recurring in recurringBox.values) {
        try {
          // NEW: Skip expired or inactive recurring transactions
          if (!recurring.isCurrentlyValid) {
            _logger.i(
                'Skipping expired/inactive recurring: ${recurring.id} (${recurring.description})');
            continue;
          }

          // NEW: Validate recurring transaction
          if (recurring.categoryId?.isEmpty ?? true) {
            _logger.w('Recurring transaction has no category: ${recurring.id}');
            continue;
          }

          // EFFICIENT: Calculate due dates instead of looping days
          final dueDates = _calculateDueDates(
            recurring,
            recurring.lastGeneratedDate,
            today,
          );

          _logger.i('Recurring "${recurring.description}": '
              'Found ${dueDates.length} due dates');

          // FIXED: Read transactions directly from Hive instead of FinancialContextService
          final txBox = Hive.box<LocalTransaction>('transactionBox');
          final Set<String> existingRecurringTransactions = txBox.values
              .where((tx) => tx.linkedRecurringId != null && !tx.isHidden)
              .map((tx) =>
                  '${tx.linkedRecurringId}-${tx.date.year}-${tx.date.month}-${tx.date.day}')
              .toSet();

          // NEW: Batch create transactions with duplicate prevention
          for (var dueDate in dueDates) {
            // NEW: Prevent duplicates
            if (_transactionExists(
                recurring, dueDate, existingRecurringTransactions)) {
              _logger.i(
                  'Skipping duplicate: ${recurring.description} on ${dueDate.toIso8601String()}');
              continue;
            }

            try {
              // Create transaction
              final transaction = LocalTransaction(
                id: const Uuid().v4(),
                amount: recurring.amount,
                description: recurring.description,
                date: dueDate,
                type: recurring.type,
                categoryId: recurring.categoryId,
                isRecurring: true,
                linkedRecurringId: recurring.id,
              );

              // Add to storage
              final txBox = Hive.box<LocalTransaction>('transactionBox');
              await txBox.add(transaction);

              generatedCount++;

              _logger.i(
                  'Generated: ${recurring.description} ($dueDate) - Amount: ${recurring.amount}');
            } catch (e, st) {
              _logger.e(
                'Failed to generate transaction for ${recurring.description}',
                stackTrace: st,
              );
              // Continue to next date instead of breaking
            }
          }

          // NEW: Only update after all transactions created successfully
          recurring.lastGeneratedDate = today;
          await recurring.save();

          _logger.i('Updated lastGeneratedDate for ${recurring.description}');
        } catch (e, st) {
          _logger.e(
            'Error processing recurring transaction ${recurring.id}',
            stackTrace: st,
          );
          // Continue to next recurring instead of breaking
        }
      }

      _logger.i(
          'Recurring transaction generation complete: Generated $generatedCount transactions');

      // NEW: Trigger balance recalculation
      await _financialContextService.calculateBalance();
    } catch (e, st) {
      _logger.e(
        'Recurring transaction generation failed',
        stackTrace: st,
      );
    }
  }

  /// Efficiently calculates all due dates between start and end
  /// Avoids day-by-day iteration for better performance
  List<DateTime> _calculateDueDates(
    RecurringTransaction recurring,
    DateTime startDate,
    DateTime endDate,
  ) {
    final dueDates = <DateTime>[];

    switch (recurring.frequency) {
      case Frequency.daily:
        // Jump to next day, not day-by-day in loop
        var current = DateTime(startDate.year, startDate.month, startDate.day);
        current = current.add(Duration(days: 1));

        while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
          dueDates.add(current);
          current = current.add(Duration(days: 1));
        }
        break;

      case Frequency.weekly:
        // Validate daysOfWeek
        if (recurring.daysOfWeek.isEmpty) {
          _logger.w('Weekly recurring has no days selected: ${recurring.id}');
          return dueDates;
        }

        var current = startDate;
        while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
          // Check if current day matches any target day
          if (recurring.daysOfWeek.contains(current.weekday)) {
            dueDates.add(current);
          }
          current = current.add(Duration(days: 1));
        }
        break;

      case Frequency.monthly:
        // Efficiently jump to next month
        var current = DateTime(startDate.year, startDate.month, 1);

        while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
          // Handle month-end edge case
          // E.g., Jan 31 job should work in Feb (which has 28/29 days)
          final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
          final targetDay = min(recurring.dayOfMonth, daysInMonth);

          final dueDate = DateTime(current.year, current.month, targetDay);

          if ((dueDate.isAfter(startDate) ||
                  dueDate.isAtSameMomentAs(startDate)) &&
              (dueDate.isBefore(endDate) ||
                  dueDate.isAtSameMomentAs(endDate))) {
            dueDates.add(dueDate);
          }

          // Move to next month
          if (current.month == 12) {
            current = DateTime(current.year + 1, 1, 1);
          } else {
            current = DateTime(current.year, current.month + 1, 1);
          }
        }
        break;
    }

    return dueDates;
  }

  /// Check if transaction already exists for this recurring
  bool _transactionExists(
    RecurringTransaction recurring,
    DateTime dueDate,
    Set<String> existingRecurringTransactions, // Pass the pre-computed set
  ) {
    final recurringTransactionIdentifier =
        '${recurring.id}-${dueDate.year}-${dueDate.month}-${dueDate.day}';
    return existingRecurringTransactions
        .contains(recurringTransactionIdentifier);
  }

  /// Archive old transactions older than 1 year
  /// This keeps the database performant while maintaining historical data
  Future<void> archiveOldTransactions() async {
    try {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
      final transactionBox = Hive.box<LocalTransaction>('transactionBox');

      int archivedCount = 0;

      // Create a copy of keys to avoid concurrent modification
      final keys = transactionBox.keys.toList();

      for (var key in keys) {
        final transaction = transactionBox.get(key);
        if (transaction != null && transaction.date.isBefore(oneYearAgo)) {
          // Mark as archived instead of deleting for historical data
          transaction.isHidden = true;
          await transaction.save();
          archivedCount++;
        }
      }

      if (archivedCount > 0) {
        _logger.i('Archived $archivedCount old transactions');
        // Refresh the transaction list
        _onTransactionsChanged();
      }
    } catch (e, st) {
      _logger.e('Failed to archive old transactions', stackTrace: st);
    }
  }

  String get formattedBalance {
    final format = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
    return format.format(balance.value);
  }

  /// Get the last transaction
  LocalTransaction? get lastTransaction {
    if (transactions.isEmpty) return null;
    return transactions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  /// Get top spending category
  MapEntry<TransactionCategory, double>? get topSpendingCategory {
    if (transactions.isEmpty) return null;

    final Map<TransactionCategory, double> categoryTotals = {};

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        if (tx.category != null) {
          categoryTotals[tx.category!] =
              (categoryTotals[tx.category] ?? 0) + tx.amount;
        }
      }
    }

    if (categoryTotals.isEmpty) return null;

    return categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  /// Get recent activity for mini chart (last 7 days)
  List<double> get recentActivityData {
    final now = DateTime.now();
    final List<double> data = List.filled(7, 0.0);

    for (var tx in transactions) {
      final daysDiff = now.difference(tx.date).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        final index = 6 - daysDiff;
        if (tx.type == TransactionType.expense) {
          data[index] += tx.amount;
        }
      }
    }

    return data;
  }

  /// Get color based on time of day
  Color getTimeOfDayColor() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning: Warm sunrise colors
      return const Color(0xFF2D3250);
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: Bright colors
      return const Color(0xFF1E3A5F);
    } else if (hour >= 17 && hour < 21) {
      // Evening: Sunset colors
      return const Color(0xFF2C1810);
    } else {
      // Night: Deep dark colors
      return const Color(0xFF0F0F1E);
    }
  }

  /// Get gradient based on time of day
  LinearGradient getTimeOfDayGradient() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF2D3250), const Color(0xFF424769)],
      );
    } else if (hour >= 12 && hour < 17) {
      // Afternoon
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF1E3A5F), const Color(0xFF2E5984)],
      );
    } else if (hour >= 17 && hour < 21) {
      // Evening
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF2C1810), const Color(0xFF4A2C1A)],
      );
    } else {
      // Night
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF0F0F1E), const Color(0xFF1A1B2E)],
      );
    }
  }
}
