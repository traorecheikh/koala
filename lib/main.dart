import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:koaa/app/core/theme.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/local_user.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/background_worker.dart';
import 'package:koaa/app/services/notification_service.dart';
import 'package:koaa/hive_registrar.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/services/data_migration_service.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/settings/controllers/settings_controller.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'package:koaa/app/services/celebration_service.dart';
import 'package:koaa/app/services/encryption_service.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Initialize Notifications & Background Worker
  await NotificationService.initialize();
  Workmanager().initialize(
    callbackDispatcher, // From background_worker.dart
    isInDebugMode: false, // Set true to test more frequently (15min)
  );
  // Schedule the daily check (runs periodically every 24h)
  Workmanager().registerPeriodicTask(
    "1", 
    kDailyCheckTask, 
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 15), // First run after 15m
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: true,
    ),
  );
  
  final appDocDir = await getApplicationDocumentsDirectory();

  // Initialize Hive with encryption for sensitive data
  Hive.init(appDocDir.path);
  Hive.registerAdapters();

  // Get encryption key for sensitive boxes
  final encryptionService = EncryptionService();
  final encryptionKey = await encryptionService.getEncryptionKey();
  final hiveCipher = HiveAesCipher(encryptionKey);

  // Open boxes with encryption for sensitive financial data
  await Hive.openBox<LocalUser>('userBox', encryptionCipher: hiveCipher);
  await Hive.openBox<LocalTransaction>('transactionBox', encryptionCipher: hiveCipher);
  await Hive.openBox<RecurringTransaction>('recurringTransactionBox', encryptionCipher: hiveCipher);
  await Hive.openBox<Job>('jobBox', encryptionCipher: hiveCipher);
  await Hive.openBox<SavingsGoal>('savingsGoalBox', encryptionCipher: hiveCipher);
  await Hive.openBox<Budget>('budgetBox', encryptionCipher: hiveCipher);
  await Hive.openBox<Debt>('debtBox', encryptionCipher: hiveCipher);
  await Hive.openBox<FinancialGoal>('financialGoalBox', encryptionCipher: hiveCipher);

  // Non-sensitive boxes without encryption for better performance
  await Hive.openBox<Category>('categoryBox');
  await Hive.openBox('settingsBox');

  
  // Run data migrations
  final migrationService = DataMigrationService();
  await migrationService.runMigrations();

  // Initialize FinancialContextService
  Get.put<FinancialContextService>(FinancialContextService(), permanent: true);

  // Initialize FinancialEventsService
  Get.put<FinancialEventsService>(FinancialEventsService(), permanent: true);

  // Initialize CelebrationService
  Get.put<CelebrationService>(CelebrationService(), permanent: true);

  // await Hive.deleteFromDisk();

  // Initialize ML Engine
  await Get.putAsync<KoalaMLEngine>(() async {
    return await KoalaMLEngine().init(hiveCipher); // Pass the cipher
  });

  // Initialize Intelligence Service (Koala Brain)
  await Get.putAsync<IntelligenceService>(() async {
    final service = IntelligenceService();
    await service.onInit();
    return service;
  });

  // Initialize SettingsController globally to ensure theme and settings are applied on startup
  Get.put<SettingsController>(SettingsController(), permanent: true);

  Get.lazyPut<CategoriesController>(
    () => CategoriesController(),
    fenix: true,
  );

  // Register Lifecycle Listener
  WidgetsBinding.instance.addObserver(AppLifecycleListener());

  runApp(AppInfo(data: await AppInfoData.get(), child: const MyApp()));

}


class AppLifecycleListener extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      try {
        // Check if welcome notification was already shown
        final welcomeShown = Hive.box('settingsBox').get('welcomeShown', defaultValue: false);

        // Only schedule notification if welcome has NOT been shown yet
        if (welcomeShown == false || welcomeShown == null) {
          // User left the app: Schedule notification in 10 minutes
          Workmanager().registerOneOffTask(
            "welcome_delayed",
            kWelcomeTask,
            initialDelay: const Duration(minutes: 10),
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
        }
      } catch (e) {
        // Handle error gracefully - don't crash the app
        debugPrint('Error scheduling welcome notification: $e');
      }
    } else if (state == AppLifecycleState.resumed) {
      try {
        // User returned: Cancel the notification if it hasn't fired yet
        Workmanager().cancelByUniqueName("welcome_delayed");
      } catch (e) {
        debugPrint('Error canceling welcome notification: $e');
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "Koala",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
