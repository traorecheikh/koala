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
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/smart_financial_brain.dart';
import 'package:koaa/app/services/ml/contextual_brain.dart';
import 'package:koaa/app/services/notification_service.dart';
import 'package:koaa/app/services/pin_service.dart';
import 'package:koaa/app/services/security_service.dart';
import 'package:koaa/app/services/widget_service.dart';

import 'package:koaa/hive_registrar.g.dart';

/// Centralized service initialization
/// Keeps main.dart clean and organized
class ServiceInitializer {
  static HiveAesCipher? _hiveCipher;

  /// Initialize all app services in correct order
  static Future<void> initialize() async {
    // 1. Critical Base Layer (Parallel)
    await Future.wait([
      _initNotifications(),
      _initHive(), // Most time consuming, start early
    ]);

    // 2. Migration Layer (Sequential - depends on Hive)
    await _runMigrations();

    // 3. Service Layer (Parallel where possible)
    await _initServices();

    // 4. UI Layer (Parallel)
    _initWidgets(); // Fire and forget or await if critical for first frame
  }

  /// Initialize notification and background worker
  static Future<void> _initNotifications() async {
    await NotificationService.initialize();
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
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
      // Encrypted boxes (sensitive)
      Hive.openBox<LocalUser>('userBox', encryptionCipher: _hiveCipher),
      Hive.openBox<LocalTransaction>('transactionBox',
          encryptionCipher: _hiveCipher),
      Hive.openBox<RecurringTransaction>('recurringTransactionBox',
          encryptionCipher: _hiveCipher),
      Hive.openBox<Job>('jobBox', encryptionCipher: _hiveCipher),
      Hive.openBox<SavingsGoal>('savingsGoalBox',
          encryptionCipher: _hiveCipher),
      Hive.openBox<Budget>('budgetBox', encryptionCipher: _hiveCipher),
      Hive.openBox<Debt>('debtBox', encryptionCipher: _hiveCipher),
      Hive.openBox<FinancialGoal>('financialGoalBox',
          encryptionCipher: _hiveCipher),

      // Non-sensitive boxes
      Hive.openBox<Category>('categoryBox'),
      Hive.openBox('settingsBox'),
      Hive.openBox('insightsBox'),
      Hive.openBox<UserChallenge>('userChallengeBox'),
      Hive.openBox<UserBadge>('userBadgeBox'),
      Hive.openBox<AILearningProfile>('aiLearningBox'),
    ]);
  }

  /// Run data migrations
  static Future<void> _runMigrations() async {
    final migrationService = DataMigrationService();
    await migrationService.runMigrations();
    await ChangelogService.init();
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
    Get.lazyPut(() => SettingsController(), fenix: true);
    Get.put<PinService>(PinService(), permanent: true);
    Get.put<SecurityService>(SecurityService(), permanent: true);

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
  }

  /// Initialize widget service
  static Future<void> _initWidgets() async {
    await WidgetService.initialize();
    // Don't await updateAllWidgets in critical path
    WidgetService.updateAllWidgets();
  }
}

/// App lifecycle observer for background tasks
class KoalaLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
