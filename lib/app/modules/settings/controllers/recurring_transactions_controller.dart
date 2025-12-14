import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'dart:async'; // Added import for StreamSubscription

class RecurringTransactionsController extends GetxController {
  final recurringTransactions = <RecurringTransaction>[].obs;
  StreamSubscription? _recurringTransactionSubscription; // Store the subscription

  @override
  void onInit() {
    super.onInit();
    final recurringTransactionBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactions.assignAll(recurringTransactionBox.values.toList());
    _recurringTransactionSubscription = recurringTransactionBox.watch().listen((_) {
      recurringTransactions.assignAll(recurringTransactionBox.values.toList());
    });
  }

  @override
  void onClose() {
    _recurringTransactionSubscription?.cancel(); // Cancel the subscription
    super.onClose();
  }

  void addRecurringTransaction(RecurringTransaction transaction) {
    final recurringTransactionBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactionBox.add(transaction);
  }

  Future<void> updateRecurringTransaction(RecurringTransaction transaction) async {
    await transaction.save();
  }

  Future<void> deleteRecurringTransaction(RecurringTransaction transaction) async {
    await transaction.delete();
  }
}

