import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart'; // Needed for WidgetsFlutterBinding.ensureInitialized
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:koaa/app/data/models/local_transaction.dart'; // Import models
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/hive_registrar.g.dart'; // Import generated Hive adapters
import 'package:koaa/app/services/encryption_service.dart'; // Import encryption service
import 'package:koaa/app/services/notification_service.dart'; // NEW: Import NotificationService
import 'package:logger/logger.dart'; // For logging within the background task

const String kDailyCheckTask = "dailyCheckTask";
const String kWelcomeTask = "welcomeNotificationTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final Logger logger = Logger(
      printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, colors: false),
      level: Level.debug, // Log everything in background for now
    );

    logger.d("Background task: $task started.");

    try {
      // 1. Initialize Flutter bindings and NotificationService in this isolate
      WidgetsFlutterBinding.ensureInitialized();
      await NotificationService.initialize(); // NEW: Initialize NotificationService

      // 2. Initialize Hive (must be done in each isolate)
      final appDocDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocDir.path);
      Hive.registerAdapters(); // Register all adapters from hive_registrar.g.dart

      // 3. Initialize EncryptionService and get cipher
      final EncryptionService encryptionService = EncryptionService();
      final List<int> encryptionKey = await encryptionService.getEncryptionKey();
      final HiveAesCipher hiveCipher = HiveAesCipher(encryptionKey);
      
      // 4. Open encrypted boxes required by background tasks
      final Box<LocalTransaction> transactionBox = await Hive.openBox<LocalTransaction>('transactionBox', encryptionCipher: hiveCipher);
      final Box<Budget> budgetBox = await Hive.openBox<Budget>('budgetBox', encryptionCipher: hiveCipher);
      final Box<RecurringTransaction> recurringTransactionBox = await Hive.openBox<RecurringTransaction>('recurringTransactionBox', encryptionCipher: hiveCipher);
      final Box settingsBox = await Hive.openBox('settingsBox'); // Needed for welcomeShown flag

      switch (task) {
        case kDailyCheckTask:
          logger.d("Executing daily check task...");
          
          logger.d("Transaction count: ${transactionBox.length}");
          logger.d("Budget count: ${budgetBox.length}");
          logger.d("Recurring transaction count: ${recurringTransactionBox.length}");

          if (transactionBox.isNotEmpty) {
            final latestTx = transactionBox.values.last;
            logger.d("Latest transaction description: ${latestTx.description}");
          }

          // Logic from previous _runDailyCheck, adapted:
          final budgets = budgetBox.values.toList();
          final transactions = transactionBox.values.toList(); // Use the opened box
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);

          for (var budget in budgets) {
            final spent = transactions
                .where((t) =>
                    t.type == TransactionType.expense &&
                    t.categoryId == budget.categoryId &&
                    t.date.isAfter(startOfMonth))
                .fold(0.0, (sum, t) => sum + t.amount);

            final percent = budget.amount > 0 ? spent / budget.amount : 0.0;

            if (percent >= 0.9 && percent < 1.0) {
              await NotificationService.showNotification(
                id: budget.hashCode,
                title: 'Attention Budget !',
                body: 'Vous avez utilisé 90% de votre budget pour la catégorie ${budget.categoryId}.', // Use categoryId as name is not here
              );
            } else if (percent >= 1.0) {
              await NotificationService.showNotification(
                id: budget.hashCode,
                title: 'Budget Dépassé',
                body: 'Alerte: Vous avez dépassé votre limite mensuelle pour la catégorie ${budget.categoryId} !',
              );
            }
          }

          // Weekly Summary (Every Monday)
          if (now.weekday == DateTime.monday) {
            final lastMonday = now.subtract(const Duration(days: 7));
            final weeklySpend = transactions
                .where((t) =>
                    t.type == TransactionType.expense &&
                    t.date.isAfter(lastMonday) &&
                    t.date.isBefore(now))
                .fold(0.0, (sum, t) => sum + t.amount);

            if (weeklySpend > 0) {
              await NotificationService.showNotification(
                id: 999, // Unique ID for summary
                title: 'Bilan Hebdomadaire',
                body: 'Vous avez dépensé ${weeklySpend.toStringAsFixed(0)} F la semaine dernière.',
              );
            }
          }

          // Daily Reminder (Every day)
          final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
          final hasRecentTransactions = transactions.any((t) => t.date.isAfter(twentyFourHoursAgo));

          if (!hasRecentTransactions) {
            await NotificationService.showNotification(
              id: 998,
              title: 'N\'oubliez pas vos dépenses !',
              body: 'Avez-vous dépensé quelque chose aujourd\'hui ? Ajoutez-le maintenant pour garder votre budget à jour.',
            );
          }
          break;

        case kWelcomeTask:
          logger.d("Executing welcome notification task...");
          final welcomeShown = settingsBox.get('welcomeShown', defaultValue: false);
          if (welcomeShown == false || welcomeShown == null) {
            await NotificationService.showWelcomeNotification(); // Use the new method
            settingsBox.put('welcomeShown', true); // Mark as shown
          }
          break;
      }
      logger.d("Background task: $task completed successfully.");
      return Future.value(true);
    } catch (e, st) {
      logger.e("Error executing background task $task: $e", stackTrace: st);
      return Future.value(false); // Task failed
    } finally {
      await Hive.close();
      logger.d("Hive boxes closed in background isolate.");
    }
  });
}

Future<void> _runDailyCheck() async {
  // 0. Initialize Notifications in this isolate
  await NotificationService.initialize();

  // 1. Initialize Hive in this separate isolate
  // Note: We need path_provider to get the app directory again
  // because we are not in the main UI isolate.
  try {
    // path_provider might not work in background on some Android versions 
    // without Flutter engine attached, but workmanager usually handles this.
    // Ideally, pass the path from main isolate via inputData if possible, 
    // but standard init often works.
    final appDocDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocDir.path);
    
    // Register Adapters (MUST match main.dart)
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TransactionTypeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(LocalTransactionAdapter());
    if (!Hive.isAdapterRegistered(40)) Hive.registerAdapter(BudgetAdapter());

    // 2. Open Boxes
    final txBox = await Hive.openBox<LocalTransaction>('transactionBox');
    final budgetBox = await Hive.openBox<Budget>('budgetBox');

    // 3. Logic: Check Budgets
    final budgets = budgetBox.values.toList();
    final transactions = txBox.values.toList();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    for (var budget in budgets) {
      final spent = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.categoryId == budget.categoryId &&
              t.date.isAfter(startOfMonth))
          .fold(0.0, (sum, t) => sum + t.amount);

      final percent = spent / budget.amount;

      if (percent >= 0.9 && percent < 1.0) {
        await NotificationService.showNotification(
          id: budget.hashCode,
          title: 'Attention Budget !',
          body: 'Vous avez utilisé 90% de votre budget pour cette catégorie.',
        );
      } else if (percent >= 1.0) {
        await NotificationService.showNotification(
          id: budget.hashCode,
          title: 'Budget Dépassé',
          body: 'Alerte: Vous avez dépassé votre limite mensuelle !',
        );
      }
    }

    // 4. Logic: Weekly Summary (Every Monday)
    if (now.weekday == DateTime.monday) {
      // Calculate last week's spending
      final lastMonday = now.subtract(const Duration(days: 7));
      final weeklySpend = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(lastMonday) &&
              t.date.isBefore(now))
          .fold(0.0, (sum, t) => sum + t.amount);

      if (weeklySpend > 0) {
        await NotificationService.showNotification(
          id: 999, // Unique ID for summary
          title: 'Bilan Hebdomadaire',
          body: 'Vous avez dépensé ${weeklySpend.toStringAsFixed(0)} F la semaine dernière.',
        );
      }
    }

    // 5. Logic: Daily Reminder (Every day)
    // Check if any transaction was added in the last 24 hours
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    final hasRecentTransactions = transactions.any((t) => t.date.isAfter(twentyFourHoursAgo));

    if (!hasRecentTransactions) {
      await NotificationService.showNotification(
        id: 998,
        title: 'N\'oubliez pas vos dépenses !',
        body: 'Avez-vous dépensé quelque chose aujourd\'hui ? Ajoutez-le maintenant pour garder votre budget à jour.',
      );
    }
    
    // Close boxes to be safe
    await txBox.close();
    await budgetBox.close();

  } catch (e) {
    print("Background Worker Error: $e");
  }
}
