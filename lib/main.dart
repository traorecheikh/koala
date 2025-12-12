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
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';

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

  Hive.init(appDocDir.path);
  Hive.registerAdapters();
  await Hive.openBox<LocalUser>('userBox');
  await Hive.openBox<LocalTransaction>('transactionBox');
  await Hive.openBox<RecurringTransaction>('recurringTransactionBox');
  await Hive.openBox<Job>('jobBox');
  await Hive.openBox<SavingsGoal>('savingsGoalBox');
  await Hive.openBox<Category>('categoryBox');
  await Hive.openBox<Budget>('budgetBox');
  await Hive.openBox<Debt>('debtBox');
  // await Hive.deleteFromDisk();

  // Initialize ML Engine
  await Get.putAsync<KoalaMLEngine>(() async {
    return await KoalaMLEngine().init();
  });

  // Initialize Intelligence Service (Koala Brain)
  await Get.putAsync<IntelligenceService>(() async {
    final service = IntelligenceService();
    await service.onInit();
    return service;
  });
      Get.lazyPut<CategoriesController>(
      () => CategoriesController(),
      fenix: true,
    );

  runApp(AppInfo(data: await AppInfoData.get(), child: const MyApp()));
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
