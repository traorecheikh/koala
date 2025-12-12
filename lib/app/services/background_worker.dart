import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

// Key for the background task
const String kDailyCheckTask = "koala_daily_check";

@pragma('vm:entry-point') // Mandatory for background isolates
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kDailyCheckTask) {
      await _runDailyCheck();
    }
    return Future.value(true);
  });
}

Future<void> _runDailyCheck() async {
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
    
    // Close boxes to be safe
    await txBox.close();
    await budgetBox.close();

  } catch (e) {
    print("Background Worker Error: $e");
  }
}
