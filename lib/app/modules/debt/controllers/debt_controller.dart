import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:uuid/uuid.dart';

class DebtController extends GetxController {
  final debts = <Debt>[].obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box<Debt>('debtBox');
    debts.assignAll(box.values.toList());
    box.watch().listen((_) => debts.assignAll(box.values.toList()));
  }

  Future<void> addDebt({
    required String personName,
    required double amount,
    required DebtType type,
    DateTime? dueDate,
  }) async {
    final box = Hive.box<Debt>('debtBox');
    final debt = Debt(
      id: const Uuid().v4(),
      personName: personName,
      originalAmount: amount,
      remainingAmount: amount,
      type: type,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    await box.add(debt);
  }

  Future<void> recordRepayment(Debt debt, double amount) async {
    // 1. Create transaction
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');
    final tx = LocalTransaction(
      amount: amount,
      description: 'Remboursement: ${debt.personName}',
      date: DateTime.now(),
      type: debt.type == DebtType.lent ? TransactionType.income : TransactionType.expense,
      category: null, // Could be 'Debt' category if added
    );
    await transactionBox.add(tx);

    // 2. Update Debt
    debt.remainingAmount -= amount;
    if (debt.remainingAmount < 0) debt.remainingAmount = 0;
    // debt.transactionIds.add(tx.key.toString()); // If we had ID
    await debt.save();
  }
}
