import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'dart:io';
import 'package:isar_plus/isar_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/challenge.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/data/models/envelope.dart';
import 'package:koaa/app/services/envelope_service.dart';

import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/controllers/recurring_transactions_controller.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart';

import 'package:koaa/app/services/background_worker.dart';
import 'package:koaa/app/services/celebration_service.dart';
import 'package:koaa/app/services/changelog_service.dart';
import 'package:koaa/app/services/data_migration_service.dart';
import 'package:koaa/app/services/encryption_service.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/intelligence/ai_learning_profile.dart';
import 'package:koaa/app/services/intelligence/ai_learning_service.dart';
import 'package:koaa/app/services/achievements_service.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/smart_financial_brain.dart';
import 'package:koaa/app/services/ml/contextual_brain.dart';
import 'package:koaa/app/services/notification_service.dart';
import 'package:koaa/app/services/pin_service.dart';
import 'package:koaa/app/services/security_service.dart';
import 'package:koaa/app/services/widget_service.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:koaa/hive_registrar.g.dart';

/// Centralized service initialization
/// Keeps main.dart clean and organized
class ServiceInitializer {
  static HiveAesCipher? _hiveCipher;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Initialize all app services in correct order
  static Future<void> initialize() async {
    // 1. Critical Base Layer (Parallel)
    await Future.wait([
      _initNotifications(),
      _initHive(), // Most time consuming, start early
    ]);

    // 2. Isar Layer (Sequential - after Hive for migration)
    await IsarService.init();

    // 3. Migration Layer (Sequential - depends on Hive + Isar)
    await _runMigrations();

    // 4. Service Layer (Parallel where possible)
    await _initServices();

    // 5. UI Layer (Parallel)
    _initWidgets(); // Fire and forget or await if critical for first frame
    print('ServiceInitializer: Initialization DONE.');
  }

  /// Initialize notification and background worker
  static Future<void> _initNotifications() async {
    await NotificationService.initialize();
    Workmanager().initialize(
      callbackDispatcher,
    );
    // Register background task
    // Using Future.microtask to not block init
    Future.microtask(() {
      Workmanager().registerPeriodicTask(
        "1",
        kDailyCheckTask,
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: true,
        ),
      );
    });
  }

  /// Initialize Hive with encryption (PARALLELIZED)
  static Future<void> _initHive() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    Hive.registerAdapters();

    // Get encryption key
    final encryptionService = EncryptionService();
    final encryptionKey = await encryptionService.getEncryptionKey();
    _hiveCipher = HiveAesCipher(encryptionKey);

    // Open all boxes in parallel to maximize IO throughput
    await Future.wait([
      // Encrypted boxes (sensitive) - with fallback for legacy unencrypted data
      _openBoxSafe<LocalUser>('userBox'),
      _openBoxSafe<LocalTransaction>('transactionBox'),
      _openBoxSafe<RecurringTransaction>('recurringTransactionBox'),
      _openBoxSafe<Job>('jobBox'),
      _openBoxSafe<SavingsGoal>('savingsGoalBox'),
      _openBoxSafe<Budget>('budgetBox'),
      _openBoxSafe<Debt>('debtBox'),
      _openBoxSafe<Debt>('debtBox'),
      _openBoxSafe<FinancialGoal>('financialGoalBox'),
      _openBoxSafe<Envelope>('envelopes'),

      // Non-sensitive boxes
      Hive.openBox<Category>('categoryBox'),
      Hive.openBox('settingsBox'),
      Hive.openBox('insightsBox'),
      Hive.openBox<UserChallenge>('userChallengeBox'),
      Hive.openBox<UserBadge>('userBadgeBox'),
      Hive.openBox<AILearningProfile>('aiLearningBox'),
    ]);

    // Apply saved dark mode immediately after Hive init
    final settingsBox = Hive.box('settingsBox');
    final savedIsDark = settingsBox.get('isDarkMode');
    if (savedIsDark != null) {
      Get.changeThemeMode(savedIsDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  /// Run data migrations
  static Future<void> _runMigrations() async {
    final migrationService = DataMigrationService();
    await migrationService.runMigrations();
    await ChangelogService.init();

    // Migrate transactions from Hive to Isar (one-time)
    await _migrateTransactionsToIsar();

    // Migrate categories from Hive to Isar (one-time)
    await _migrateCategoriesToIsar();

    // Migrate budgets from Hive to Isar (one-time)
    await _migrateBudgetsToIsar();

    // Migrate goals from Hive to Isar (one-time)
    await _migrateGoalsToIsar();

    // Phase 2: Migrate RecurringTransaction, Debt, Job from Hive to Isar (one-time)
    await _migrateRecurringTransactionsToIsar();
    await _migrateDebtsToIsar();
    await _migrateJobsToIsar();
    await _migrateLocalUserToIsar();
    await _migrateEnvelopesToIsar();

    // Rescue data from legacy DB (koala_isar) to current (koala_isar_v5)
    await _rescueLegacyData();
  }

  /// One-time migration of transactions from Hive to Isar
  static Future<void> _migrateTransactionsToIsar() async {
    // V6: Added LocalUser, SavingsGoal, Envelope schemas (koala_isar)
    final migrated = await _secureStorage.read(key: 'isar_tx_migration_v6');

    if (migrated == 'true') {
      final hiveCount = Hive.box<LocalTransaction>('transactionBox').length;
      if (hiveCount > 0) {
        // If somehow data appeared again, warn but don't auto-migrate blindly to avoid loops
        debugPrint(
            '[Migration] Warning: transactionBox has $hiveCount items despite V2 flag.');
      }
      return;
    }

    try {
      debugPrint(
          '[Migration] Starting Hive → Isar transaction migration (V2 Sweep)...');
      final hiveBox = Hive.box<LocalTransaction>('transactionBox');
      final transactions = hiveBox.values.toList();

      if (transactions.isEmpty) {
        debugPrint(
            '[Migration] Hive transactionBox is empty. Nothing to migrate.');
      } else {
        debugPrint(
            '[Migration] Migrating ${transactions.length} legacy transactions...');

        // Optimize: Process in chunks to avoid blocking UI
        const chunkSize = 200;
        for (var i = 0; i < transactions.length; i += chunkSize) {
          final end = (i + chunkSize < transactions.length)
              ? i + chunkSize
              : transactions.length;
          final chunk = transactions.sublist(i, end);

          // Upsert to Isar (handles duplicates safely)
          IsarService.addTransactions(chunk);

          // Yield to allow UI frame rendering
          await Future.delayed(Duration.zero);
        }

        // CRITICAL: Clear the legacy box to prevent future confusion
        await hiveBox.clear();
        debugPrint(
            '[Migration] ✅ Successfully migrated ${transactions.length} items and CLEARED legacy box.');
      }

      await _secureStorage.write(key: 'isar_tx_migration_v6', value: 'true');
      debugPrint('[Migration] ✅ ALL DONE: Transaction migration complete');
    } catch (e) {
      debugPrint('[Migration] ❌ Failed to migrate transactions: $e');
      // Don't set flag - will retry on next startup
    }

    // V2: Fix Rattrapage transaction descriptions and categories
    await _fixRattrapageData();
  }

  /// V4 Migration: Fix existing 'Rattrapage' transactions
  /// Updates description to category name and ensures category enum is set
  static Future<void> _fixRattrapageData() async {
    final done = await _secureStorage.read(key: 'rattrapage_fix_v7');
    if (done == 'true') return;

    try {
      final allTx = await IsarService.getAllTransactions();
      int fixed = 0;
      int processed = 0;

      // UUID pattern (both standard and without dashes)
      final uuidPattern = RegExp(
          r'^[0-9a-fA-F]{8}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{4}-?[0-9a-fA-F]{12}$');

      // Try to load custom categories from Hive for name lookup
      Map<String, String> customCategoryNames = {};
      try {
        if (Hive.isBoxOpen('categoryBox')) {
          final categoryBox = Hive.box<Category>('categoryBox');
          for (final cat in categoryBox.values) {
            customCategoryNames[cat.id] = cat.name;
          }
        }
      } catch (_) {}

      for (final tx in allTx) {
        bool needsUpdate = false;
        final desc = tx.description.trim();

        // Check if description is a pure UUID
        final isUuidDescription = uuidPattern.hasMatch(desc) ||
            (desc.length == 36 && desc.contains('-')) ||
            (desc.length >= 32 &&
                !desc.contains(' ') &&
                RegExp(r'^[0-9a-fA-F-]+$').hasMatch(desc));

        // Check if description contains UUID after 'Rattrapage: ' prefix
        bool hasUuidInRattrapage = false;
        if (desc.startsWith('Rattrapage: ')) {
          final afterPrefix = desc.substring('Rattrapage: '.length).trim();
          hasUuidInRattrapage = uuidPattern.hasMatch(afterPrefix) ||
              (afterPrefix.length == 36 && afterPrefix.contains('-')) ||
              (afterPrefix.length >= 32 &&
                  !afterPrefix.contains(' ') &&
                  RegExp(r'^[0-9a-fA-F-]+$').hasMatch(afterPrefix));
        }

        // Fix description if it matches any problematic pattern
        // V6 Update: Broader check for 'rattrapage' and REMOVE prefix
        if (desc.toLowerCase().contains('rattrapage') ||
            desc == 'Rattrapage' ||
            isUuidDescription ||
            hasUuidInRattrapage) {
          // Try to get proper name from categoryId or category
          String properName = 'Dépense';

          if (tx.categoryId != null && tx.categoryId!.isNotEmpty) {
            // First try enum name match
            try {
              final cat = TransactionCategory.values
                  .firstWhere((e) => e.name == tx.categoryId);
              properName = cat.displayName;
              // Also fix the category enum if it's wrong
              if (tx.category != cat) {
                tx.category = cat;
              }
            } catch (_) {
              // categoryId might be a UUID for custom category - lookup in Hive
              if (customCategoryNames.containsKey(tx.categoryId)) {
                properName = customCategoryNames[tx.categoryId]!;
              } else if (!uuidPattern.hasMatch(tx.categoryId!)) {
                // Use categoryId directly if not a UUID
                properName = tx.categoryId!;
              } else {
                // Fallback to category enum displayName
                properName = tx.category.displayName;
              }
            }
          } else {
            // No categoryId - use category enum displayName
            properName = tx.category.displayName;
          }

          tx.description = properName;
          needsUpdate = true;
          debugPrint(
              '[Migration] Fixed (Clean): ${tx.id} -> ${tx.description}');
        }

        // Also fix any transaction with 'other' category but valid categoryId
        if (tx.category == TransactionCategory.otherExpense &&
            tx.categoryId != null) {
          try {
            final cat = TransactionCategory.values
                .firstWhere((e) => e.name == tx.categoryId);
            tx.category = cat;
            needsUpdate = true;
          } catch (_) {
            // Keep as 'other' for custom categories
          }
        }

        if (needsUpdate) {
          IsarService.updateTransaction(tx);
          fixed++;
        }

        processed++;
        if (processed % 50 == 0) {
          await Future.delayed(Duration.zero);
        }
      }

      await _secureStorage.write(key: 'rattrapage_fix_v7', value: 'true');
      if (fixed > 0) {
        debugPrint('[Migration] ✅ Fixed $fixed rattrapage transactions');
      }
    } catch (e) {
      debugPrint('[Migration] ❌ Rattrapage fix failed: $e');
    }
  }

  /// One-time migration of categories from Hive to Isar
  static Future<void> _migrateCategoriesToIsar() async {
    final migrationComplete =
        await _secureStorage.read(key: 'isar_category_migration_v1');

    if (migrationComplete == 'true') {
      final hiveCount = Hive.box<Category>('categoryBox').length;
      if (hiveCount > 0) {
        debugPrint(
            '[Migration] Warning: categoryBox has $hiveCount items despite migration flag.');
      }
      return;
    }

    try {
      debugPrint('[Migration] Starting Hive → Isar category migration...');
      final hiveBox = Hive.box<Category>('categoryBox');
      final categories = hiveBox.values.toList();

      if (categories.isEmpty) {
        debugPrint(
            '[Migration] Hive categoryBox is empty. Nothing to migrate.');
      } else {
        debugPrint('[Migration] Migrating ${categories.length} categories...');

        // Categories are small, no chunking needed
        IsarService.addCategories(categories);

        // CRITICAL: Clear the legacy box to prevent future confusion
        await hiveBox.clear();
        debugPrint('[Migration] ✅ Category migration complete');
      }

      await _secureStorage.write(
          key: 'isar_category_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Category migration failed: $e');
      debugPrint('[Migration] Stack: $stack');
      rethrow;
    }
  }

  /// One-time migration of budgets from Hive to Isar
  static Future<void> _migrateBudgetsToIsar() async {
    final migrationComplete =
        await _secureStorage.read(key: 'isar_budget_migration_v1');

    if (migrationComplete == 'true') {
      return;
    }

    try {
      debugPrint('[Migration] Starting Hive → Isar budget migration...');
      final hiveBox = Hive.box<Budget>('budgetBox');
      final budgets = hiveBox.values.toList();

      if (budgets.isEmpty) {
        debugPrint('[Migration] Hive budgetBox is empty. Nothing to migrate.');
      } else {
        debugPrint('[Migration] Migrating ${budgets.length} budgets...');

        // Add all budgets to Isar
        IsarService.addBudgets(budgets);

        // Clear Hive box
        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive budgetBox');
      }

      debugPrint('[Migration] ✅ Budget migration complete');
      await _secureStorage.write(
          key: 'isar_budget_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Budget migration failed: $e');
      debugPrint('[Migration] Stack: $stack');
      rethrow;
    }
  }

  /// One-time migration of financial goals from Hive to Isar
  static Future<void> _migrateGoalsToIsar() async {
    final migrationComplete =
        await _secureStorage.read(key: 'isar_goal_migration_v1');

    if (migrationComplete == 'true') {
      return;
    }

    try {
      debugPrint('[Migration] Starting Hive → Isar goal migration...');
      final hiveBox = Hive.box<FinancialGoal>('financialGoalBox');
      final goals = hiveBox.values.toList();

      if (goals.isEmpty) {
        debugPrint(
            '[Migration] Hive financialGoalBox is empty. Nothing to migrate.');
      } else {
        debugPrint('[Migration] Migrating ${goals.length} goals...');

        // Add all goals to Isar
        IsarService.addGoals(goals);

        // Clear Hive box
        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive financialGoalBox');
      }

      debugPrint('[Migration] ✅ Goal migration complete');
      await _secureStorage.write(key: 'isar_goal_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Goal migration failed: $e');
      debugPrint('[Migration] Stack: $stack');
      rethrow;
    }
  }

  /// One-time migration of recurring transactions from Hive to Isar
  static Future<void> _migrateRecurringTransactionsToIsar() async {
    try {
      final migrated =
          await _secureStorage.read(key: 'isar_recurring_tx_migration_v1');
      if (migrated == 'true') {
        debugPrint(
            '[Migration] Recurring transactions already migrated to Isar');
        return;
      }

      final hiveBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
      if (hiveBox.isNotEmpty) {
        debugPrint(
            '[Migration] Migrating ${hiveBox.length} recurring transactions to Isar');
        final transactions = hiveBox.values.toList();

        // Sanitize IDs
        for (var item in transactions) {
          if (item.id.isEmpty) {
            item.id = const Uuid().v4();
          }
        }

        IsarService.addRecurringTransactions(transactions);
        debugPrint('[Migration] Migrated recurring transactions to Isar');

        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive recurringTransactionBox');
      }

      debugPrint('[Migration] ✅ Recurring transaction migration complete');
      await _secureStorage.write(
          key: 'isar_recurring_tx_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Recurring transaction migration failed: $e');
      // Fix: Don't rethrow to allow app to proceed even if this fails
      // rethrow;
    }
  }

  /// One-time migration of debts from Hive to Isar
  static Future<void> _migrateDebtsToIsar() async {
    try {
      final migrated = await _secureStorage.read(key: 'isar_debt_migration_v1');
      if (migrated == 'true') {
        debugPrint('[Migration] Debts already migrated to Isar');
        return;
      }

      final hiveBox = Hive.box<Debt>('debtBox');
      if (hiveBox.isNotEmpty) {
        debugPrint('[Migration] Migrating ${hiveBox.length} debts to Isar');
        final debts = hiveBox.values.toList();

        // Sanitize IDs
        for (var item in debts) {
          if (item.id.isEmpty) {
            item.id = const Uuid().v4();
          }
        }

        IsarService.addDebts(debts);
        debugPrint('[Migration] Migrated debts to Isar');

        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive debtBox');
      }

      debugPrint('[Migration] ✅ Debt migration complete');
      await _secureStorage.write(key: 'isar_debt_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Debt migration failed: $e');
      // Fix: Don't rethrow
      // rethrow;
    }
  }

  /// One-time migration of jobs from Hive to Isar
  static Future<void> _migrateJobsToIsar() async {
    try {
      final migrated = await _secureStorage.read(key: 'isar_job_migration_v1');
      if (migrated == 'true') {
        debugPrint('[Migration] Jobs already migrated to Isar');
        return;
      }

      final hiveBox = Hive.box<Job>('jobBox');
      if (hiveBox.isNotEmpty) {
        debugPrint('[Migration] Migrating ${hiveBox.length} jobs to Isar');
        final jobs = hiveBox.values.toList();

        // Sanitize IDs to prevent 'Illegal Argument'
        for (var item in jobs) {
          if (item.id.isEmpty) {
            item.id = const Uuid().v4();
          }
        }

        IsarService.addJobs(jobs);
        debugPrint('[Migration] Migrated jobs to Isar');

        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive jobBox');
      }

      debugPrint('[Migration] ✅ Job migration complete');
      await _secureStorage.write(key: 'isar_job_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Job migration failed: $e');
      // Fix: Don't rethrow
      // rethrow;
    }
  }

  /// One-time migration of user from Hive to Isar
  static Future<void> _migrateLocalUserToIsar() async {
    try {
      final migrated = await _secureStorage.read(key: 'isar_user_migration_v1');
      if (migrated == 'true') {
        debugPrint('[Migration] User already migrated to Isar');
        return;
      }

      final hiveBox = Hive.box<LocalUser>('userBox');
      if (hiveBox.isNotEmpty) {
        debugPrint('[Migration] Migrating user to Isar');
        final user = hiveBox.values.first;

        // Ensure ID is valid to prevent IsarError: Illegal Argument
        // Always regenerate ID to prevent IsarError: Illegal Argument from old/invalid IDs
        debugPrint('[Migration] Original User ID: ${user.id}');
        user.id = const Uuid().v4();
        debugPrint('[Migration] Regenerated UUID for user: ${user.id}');

        await IsarService.saveUser(user);
        debugPrint('[Migration] Migrated user to Isar');

        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive userBox');
      }

      debugPrint('[Migration] ✅ User migration complete');
      await _secureStorage.write(key: 'isar_user_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ User migration failed: $e');
      debugPrint('[Migration] Stack: $stack');
      // rethrow; // Allow other migrations (specifically Rescue) to proceed
    }
  }

  /// One-time migration of savings goals from Hive to Isar
  static Future<void> _migrateSavingsGoalsToIsar() async {
    try {
      final migrated =
          await _secureStorage.read(key: 'isar_savings_goal_migration_v1');
      if (migrated == 'true') {
        debugPrint('[Migration] Savings goals already migrated to Isar');
        return;
      }

      final hiveBox = Hive.box<SavingsGoal>('savingsGoalBox');
      if (hiveBox.isNotEmpty) {
        debugPrint(
            '[Migration] Migrating ${hiveBox.length} savings goals to Isar');
        final goals = hiveBox.values.toList();
        IsarService.addSavingsGoals(goals);
        debugPrint('[Migration] Migrated savings goals to Isar');

        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive savingsGoalBox');
      }

      debugPrint('[Migration] ✅ Savings goal migration complete');
      await _secureStorage.write(
          key: 'isar_savings_goal_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Savings goal migration failed: $e');
      debugPrint('[Migration] Stack: $stack');
      rethrow;
    }
  }

  /// Initialize all GetX services
  static Future<void> _initServices() async {
    // Core financial services (Fast, Synch)
    Get.put<FinancialContextService>(FinancialContextService(),
        permanent: true);
    Get.put<FinancialEventsService>(FinancialEventsService(), permanent: true);
    Get.put<CelebrationService>(CelebrationService(), permanent: true);

    // Controllers (Lazy Load with Fenix=true)
    Get.lazyPut(() => RecurringTransactionsController(), fenix: true);
    Get.lazyPut<CategoriesController>(() => CategoriesController(),
        fenix: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<PinService>(PinService(), permanent: true);
    Get.put<SecurityService>(SecurityService(), permanent: true);
    Get.put<AchievementsService>(AchievementsService(), permanent: true);

    // Heavy ML Services - Parallelize initialization
    await Future.wait([
      Get.putAsync<KoalaMLEngine>(() async {
        return await KoalaMLEngine().init(_hiveCipher!);
      }),
      Get.putAsync<AILearningService>(() async {
        final service = AILearningService();
        await service.onInit();
        return service;
      }),
    ]);

    // Brains (Depend on Context, so they stay after ContextService)
    // Note: SmartFinancialBrain does heavy work onInit.
    // We will optimize the Brain itself separately (Isolates).
    final brain = SmartFinancialBrain();
    Get.put<SmartFinancialBrain>(brain, permanent: true);
    Get.put<ContextualBrain>(ContextualBrain(), permanent: true);

    // Intelligence Service (Depends on Brains)
    await Get.putAsync<IntelligenceService>(() async {
      final service = IntelligenceService();
      await service.onInit();
      return service;
    });

    // Envelopes (Smart Envelopes Feature)
    await Get.putAsync<EnvelopeService>(() async {
      final service = EnvelopeService();
      await service.init();
      return service;
    });
  }

  /// Initialize widget service
  static Future<void> _initWidgets() async {
    await WidgetService.initialize();
    // Don't await updateAllWidgets in critical path
    WidgetService.updateAllWidgets();
  }

  /// One-time migration of envelopes from Hive to Isar
  static Future<void> _migrateEnvelopesToIsar() async {
    try {
      final migrated =
          await _secureStorage.read(key: 'isar_envelope_migration_v1');
      if (migrated == 'true') {
        debugPrint('[Migration] Envelopes already migrated to Isar');
        return;
      }

      final hiveBox = Hive.box<Envelope>('envelopes');
      if (hiveBox.isNotEmpty) {
        debugPrint('[Migration] Migrating ${hiveBox.length} envelopes to Isar');
        final envelopes = hiveBox.values.toList();
        IsarService.addEnvelopes(envelopes);
        debugPrint('[Migration] Migrated envelopes to Isar');

        await hiveBox.clear();
        debugPrint('[Migration] Cleared Hive envelopes');
      }

      debugPrint('[Migration] ✅ Envelope migration complete');
      await _secureStorage.write(
          key: 'isar_envelope_migration_v1', value: 'true');
    } catch (e, stack) {
      debugPrint('[Migration] ❌ Envelope migration failed: $e');
      debugPrint('[Migration] Stack: $stack');
      rethrow;
    }
  }

  /// Rescue data (Jobs, Debts, Recurring) from koala_isar_v5 if it exists

  /// Rescue data from legacy database (koala_isar) to current (koala_isar_v5)
  static Future<void> _rescueLegacyData() async {
    try {
      final rescued =
          await _secureStorage.read(key: 'legacy_rescue_complete_v1');
      if (rescued == 'true') return;

      final dir = await getApplicationDocumentsDirectory();
      // Check if legacy exists
      final legacyExists = Directory(dir.path)
          .listSync()
          .any((f) => f.path.contains('koala_isar') && !f.path.contains('v5'));

      if (!legacyExists) {
        await _secureStorage.write(
            key: 'legacy_rescue_complete_v1', value: 'true');
        return;
      }

      debugPrint(
          '[Rescue] Attempting to rescue data from legacy koala_isar...');

      // Open Legacy instance (Try-Catch in case of version crash)
      final legacy = await Isar.open(
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
          EnvelopeSchema
        ],
        directory: dir.path,
        name: 'koala_isar', // Legacy name
      );

      // Rescue Transactions
      try {
        final txs = await legacy.localTransactions.where().findAllAsync();
        if (txs.isNotEmpty) {
          debugPrint(
              '[Rescue] Found ${txs.length} transactions in legacy. Copying...');
          IsarService.addTransactions(txs);
        }
      } catch (e) {
        debugPrint('[Rescue] Legacy Transactions failed: $e');
      }

      // Rescue Jobs
      try {
        final jobs = await legacy.jobs.where().findAllAsync();
        if (jobs.isNotEmpty) {
          debugPrint(
              '[Rescue] Found ${jobs.length} jobs in legacy. Copying...');
          IsarService.addJobs(jobs);
        }
      } catch (e) {
        debugPrint('[Rescue] Legacy Jobs failed: $e');
      }

      // Rescue Debts
      try {
        final debts = await legacy.debts.where().findAllAsync();
        if (debts.isNotEmpty) {
          debugPrint(
              '[Rescue] Found ${debts.length} debts in legacy. Copying...');
          IsarService.addDebts(debts);
        }
      } catch (e) {
        debugPrint('[Rescue] Legacy Debts failed: $e');
      }

      // Rescue Recurring
      try {
        final recurring =
            await legacy.recurringTransactions.where().findAllAsync();
        if (recurring.isNotEmpty) {
          debugPrint(
              '[Rescue] Found ${recurring.length} recurring tx in legacy. Copying...');
          IsarService.addRecurringTransactions(recurring);
        }
      } catch (e) {
        debugPrint('[Rescue] Legacy Recurring failed: $e');
      }

      // Rescue User
      try {
        final legacyUser = await legacy.localUsers.where().findFirstAsync();
        if (legacyUser != null) {
          final currentUser = IsarService.getUser();
          if (currentUser == null) {
            debugPrint('[Rescue] Restoring user from legacy...');

            // Ensure valid ID for legacy user too
            if (legacyUser.id.isEmpty) {
              legacyUser.id = const Uuid().v4();
            }

            await IsarService.saveUser(legacyUser);
          }
        }
      } catch (e) {
        debugPrint('[Rescue] Legacy User failed: $e');
      }

      await legacy.close();
      debugPrint('[Rescue] Legacy rescue complete.');
      await _secureStorage.write(
          key: 'legacy_rescue_complete_v1', value: 'true');
    } catch (e) {
      debugPrint('[Rescue] Critical Failure opening legacy DB: $e');
      // If we can't open it, we can't rescue. Mark as done to prevent loop?
      // No, maybe retry later. Code changes might fix it.
    }
  }

  /// Helper to safely open a box with encryption fallback
  static Future<Box<T>> _openBoxSafe<T>(String name) async {
    try {
      return await Hive.openBox<T>(name, encryptionCipher: _hiveCipher);
    } catch (e) {
      debugPrint(
          'Warning: Failed to open encrypted box "$name" ($e). Attempting fallback to unencrypted.');
      try {
        // Fallback: Try opening without encryption (legacy data support)
        return await Hive.openBox<T>(name);
      } catch (e2) {
        debugPrint(
            'Critical: Failed to open box "$name" even without encryption: $e2');
        rethrow;
      }
    }
  }
}

/// App lifecycle observer for background tasks
class KoalaLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    NotificationService.isForeground = (state == AppLifecycleState.resumed);

    if (state == AppLifecycleState.paused) {
      _scheduleWelcomeNotification();
    } else if (state == AppLifecycleState.resumed) {
      _cancelWelcomeNotification();
    }
  }

  void _scheduleWelcomeNotification() {
    try {
      final welcomeShown =
          Hive.box('settingsBox').get('welcomeShown', defaultValue: false);
      if (welcomeShown == false || welcomeShown == null) {
        Workmanager().registerOneOffTask(
          "welcome_delayed",
          kWelcomeTask,
          initialDelay: const Duration(minutes: 10),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling welcome notification: $e');
    }
  }

  void _cancelWelcomeNotification() {
    try {
      Workmanager().cancelByUniqueName("welcome_delayed");
    } catch (e) {
      debugPrint('Error canceling welcome notification: $e');
    }
  }
}
