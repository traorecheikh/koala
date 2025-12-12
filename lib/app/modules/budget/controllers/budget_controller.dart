import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:uuid/uuid.dart';

class BudgetController extends GetxController {
  final budgets = <Budget>[].obs;
  final categories = <Category>[].obs;
  final transactions = <LocalTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final budgetBox = Hive.box<Budget>('budgetBox');
    final categoryBox = Hive.box<Category>('categoryBox');
    final transactionBox = Hive.box<LocalTransaction>('transactionBox');

    budgets.assignAll(budgetBox.values.toList());
    categories.assignAll(categoryBox.values.toList());
    transactions.assignAll(transactionBox.values.toList());

    budgetBox.watch().listen((_) => budgets.assignAll(budgetBox.values.toList()));
    transactionBox.watch().listen((_) => transactions.assignAll(transactionBox.values.toList()));
  }

  double getSpentAmount(String categoryId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return transactions
        .where((t) => 
            t.type == TransactionType.expense && 
            t.categoryId == categoryId && 
            t.date.isAfter(startOfMonth))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Category? getCategory(String id) {
    return categories.firstWhereOrNull((c) => c.id == id);
  }

  Future<void> addBudget(String categoryId, double amount) async {
    final box = Hive.box<Budget>('budgetBox');
    // Check if budget exists for category
    final existing = budgets.firstWhereOrNull((b) => b.categoryId == categoryId);
    if (existing != null) {
      existing.amount = amount;
      await existing.save();
    } else {
      final budget = Budget(
        id: const Uuid().v4(),
        categoryId: categoryId,
        amount: amount,
        startDate: DateTime.now(),
      );
      await box.add(budget);
    }
  }

  double getSuggestedBudget(String categoryId) {
    final engine = Get.find<KoalaMLEngine>();
    return engine.suggestBudgetForCategory(categoryId, transactions.toList());
  }
}
