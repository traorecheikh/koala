import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';

class RecurringTransactionsController extends GetxController {
  final recurringTransactions = <RecurringTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    final recurringTransactionBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactions.assignAll(recurringTransactionBox.values.toList());
    recurringTransactionBox.watch().listen((_) {
      recurringTransactions.assignAll(recurringTransactionBox.values.toList());
    });
  }

  void addRecurringTransaction(RecurringTransaction transaction) {
    final recurringTransactionBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactionBox.add(transaction);
  }

  void deleteRecurringTransaction(int index) {
    final recurringTransactionBox = Hive.box<RecurringTransaction>('recurringTransactionBox');
    recurringTransactionBox.deleteAt(index);
  }
}
