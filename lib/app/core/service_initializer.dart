import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

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
      _openBoxSafe<Envelope>('envelopeBox'),

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
  }

  /// One-time migration of transactions from Hive to Isar
  static Future<void> _migrateTransactionsToIsar() async {
    final migrationComplete =
        await _secureStorage.read(key: 'isar_tx_migration_v1');

    if (migrationComplete == 'true') {
      debugPrint('[Migration] Isar transaction migration already complete.');
      return;
    }

    try {
      debugPrint('[Migration] Starting Hive → Isar transaction migration...');
      final hiveBox = Hive.box<LocalTransaction>('transactionBox');
      final transactions = hiveBox.values.toList();

      if (transactions.isEmpty) {
        debugPrint('[Migration] No transactions to migrate.');
        await _secureStorage.write(key: 'isar_tx_migration_v1', value: 'true');
        return;
      }

      debugPrint(
          '[Migration] Migrating ${transactions.length} transactions...');

      // Optimize: Process in chunks to avoid blocking UI (Splash animation)
      const chunkSize = 200;
      for (var i = 0; i < transactions.length; i += chunkSize) {
        final end = (i + chunkSize < transactions.length)
            ? i + chunkSize
            : transactions.length;
        final chunk = transactions.sublist(i, end);
        IsarService.addTransactions(chunk); // Removed await (sync method)
        // Yield to allow UI frame rendering
        await Future.delayed(Duration.zero);
      }

      await _secureStorage.write(key: 'isar_tx_migration_v1', value: 'true');
      debugPrint(
          '[Migration] ✅ Successfully migrated ${transactions.length} transactions to Isar!');
    } catch (e) {
      debugPrint('[Migration] ❌ Failed to migrate transactions: $e');
      // Don't set flag - will retry on next startup
    }

    // V2: Fix Rattrapage transaction descriptions and categories
    await _fixRattrapageData();
  }

  /// V2 Migration: Fix existing 'Rattrapage' transactions
  /// Updates description to category name and ensures category enum is set
  static Future<void> _fixRattrapageData() async {
    final done = await _secureStorage.read(key: 'rattrapage_fix_v2');
    if (done == 'true') return;

    try {
      final allTx = await IsarService.getAllTransactions();
      int fixed = 0;
      int processed = 0;

      for (final tx in allTx) {
        bool needsUpdate = false;

        // Check if description is a UUID pattern (XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)
        final uuidPattern = RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
        final isUuidDescription = uuidPattern.hasMatch(tx.description);

        // Fix description if it's "Rattrapage", starts with "Rattrapage:", or is a UUID
        if (tx.description == 'Rattrapage du mois' ||
            tx.description == 'Rattrapage' ||
            tx.description.startsWith('Rattrapage:') ||
            isUuidDescription) {
          if (tx.categoryId != null) {
            try {
              final cat = TransactionCategory.values
                  .firstWhere((e) => e.name == tx.categoryId);
              tx.description = 'Rattrapage: ${cat.displayName}';
              // Also fix the category enum if it's wrong
              if (tx.category != cat) {
                tx.category = cat;
              }
              needsUpdate = true;
            } catch (_) {
              // Custom category - use a proper description
              tx.description = 'Rattrapage: ${tx.categoryId}';
              needsUpdate = true;
            }
          } else if (isUuidDescription) {
            // UUID with no categoryId - use category enum displayName
            tx.description = 'Rattrapage: ${tx.category.displayName}';
            needsUpdate = true;
          }
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
          IsarService.updateTransaction(tx); // Removed await (sync method)
          fixed++;
        }

        processed++;
        // Yield every 50 items to keep animation smooth
        if (processed % 50 == 0) {
          await Future.delayed(Duration.zero);
        }
      }

      await _secureStorage.write(key: 'rattrapage_fix_v2', value: 'true');
      if (fixed > 0) {
        debugPrint('[Migration] ✅ Fixed $fixed rattrapage transactions');
      }
    } catch (e) {
      debugPrint('[Migration] ❌ Rattrapage fix failed: $e');
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
