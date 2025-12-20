import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/ml/financial_pattern.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'dart:async'; // Added import for StreamSubscription

class RecurringTransactionsController extends GetxController {
  final recurringTransactions = <RecurringTransaction>[].obs;
  StreamSubscription?
      _recurringTransactionSubscription; // Store the subscription

  @override
  void onInit() {
    super.onInit();
    final recurringTransactionBox =
        Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactions.assignAll(recurringTransactionBox.values.toList());
    _recurringTransactionSubscription =
        recurringTransactionBox.watch().listen((_) {
      recurringTransactions.assignAll(recurringTransactionBox.values.toList());
      scanForSubscriptions(); // Rescan when recurring transactions change
    });

    // Initial scan
    scanForSubscriptions();
  }

  // Detected patterns that could be subscriptions
  final detectedSubscriptions = <FinancialPattern>[].obs;

  // Locally suppressed patterns (temporary for session or persisted later if needed)
  final _ignoredPatterns = <String>[].obs;

  void scanForSubscriptions() {
    try {
      if (!Get.isRegistered<KoalaMLEngine>()) return;

      final mlEngine = Get.find<KoalaMLEngine>();
      final patterns = mlEngine.modelStore.getAllPatterns();

      // Filter for recurring expenses
      final candidates = patterns
          .where((p) =>
              p.patternType ==
                  'recurringExpense' && // Matches PatternType.recurringExpense.name
              !_ignoredPatterns.contains(p.description))
          .toList();

      // Filter out those that match existing active recurring transactions
      // Heuristic: Same amount and roughly same description
      final filtered = candidates.where((pattern) {
        final amount =
            double.tryParse(pattern.parameters['amount'] ?? '0') ?? 0;

        final alreadyExists = recurringTransactions.any((existing) =>
                existing.isActive &&
                (existing.amount - amount).abs() < 1.0 // Matches amount
            // Could also check description similarity if needed
            );

        return !alreadyExists;
      }).toList();

      detectedSubscriptions.assignAll(filtered);
    } catch (e) {
      print('Error scanning for subscriptions: $e');
    }
  }

  void ignoreSubscription(FinancialPattern pattern) {
    _ignoredPatterns.add(pattern.description);
    detectedSubscriptions.remove(pattern);
  }

  @override
  void onClose() {
    _recurringTransactionSubscription?.cancel(); // Cancel the subscription
    super.onClose();
  }

  void addRecurringTransaction(RecurringTransaction transaction) {
    final recurringTransactionBox =
        Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactionBox.add(transaction);
  }

  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    await transaction.save();
  }

  Future<void> deleteRecurringTransaction(
      RecurringTransaction transaction) async {
    await transaction.delete();
  }

  /// Update a recurring transaction amount while preserving historical data.
  /// This ends the old recurring and creates a new one with the new amount.
  /// Past transactions remain linked to the old recurring for accurate history.
  Future<RecurringTransaction> updateRecurringAmountWithHistory({
    required RecurringTransaction oldTransaction,
    required double newAmount,
    String? newDescription,
    DateTime? newEndDate,
  }) async {
    final recurringTransactionBox =
        Hive.box<RecurringTransaction>('recurringTransactionBox');

    // 1. End the old recurring transaction (set endDate to now)
    oldTransaction.endDate = DateTime.now();
    oldTransaction.isActive = false;
    await oldTransaction.save();

    // 2. Create a new recurring transaction with the new amount
    final newTransaction = RecurringTransaction(
      amount: newAmount,
      description: newDescription ?? oldTransaction.description,
      frequency: oldTransaction.frequency,
      daysOfWeek: oldTransaction.daysOfWeek,
      dayOfMonth: oldTransaction.dayOfMonth,
      lastGeneratedDate: DateTime.now()
          .subtract(const Duration(days: 1)), // Will generate from today
      category: oldTransaction.category,
      type: oldTransaction.type,
      categoryId: oldTransaction.categoryId,
      endDate: newEndDate,
      isActive: true,
    );

    // 3. Save the new recurring transaction
    await recurringTransactionBox.add(newTransaction);

    return newTransaction;
  }

  /// Toggle active status of a recurring transaction
  Future<void> toggleRecurringActive(RecurringTransaction transaction) async {
    transaction.isActive = !transaction.isActive;
    await transaction.save();
  }

  /// Set end date for a recurring transaction
  Future<void> setRecurringEndDate(
      RecurringTransaction transaction, DateTime? endDate) async {
    transaction.endDate = endDate;
    await transaction.save();
  }
}
