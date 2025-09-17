import 'package:get/get.dart';
import 'package:koala/app/data/models/account_model.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/data/models/user_model.dart';
import 'package:koala/app/data/services/hive_service.dart';
import 'package:koala/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final currentUser = Rxn<UserModel>();
  final recentTransactions = <TransactionModel>[].obs;
  final accounts = <AccountModel>[].obs;
  final isLoading = false.obs;

  final monthlyIncome = 0.0.obs;
  final monthlyExpenses = 0.0.obs;
  final monthlyBudget = 150000.0.obs; // Default budget of 150,000 XOF
  final selectedBottomIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Load current user
      final user = HiveService.users.get('current_user');
      if (user == null) {
        Get.offAllNamed(Routes.onboarding);
        return;
      }
      currentUser.value = user;

      // Load accounts
      final userAccounts = HiveService.accounts.values
          .where((account) => account.userId == user.id)
          .toList();
      accounts.assignAll(userAccounts);

      // Load recent transactions (last 10)
      final allTransactions = HiveService.transactions.values
          .where((tx) => tx.userId == user.id)
          .toList();

      allTransactions.sort((a, b) => b.date.compareTo(a.date));
      recentTransactions.assignAll(allTransactions.take(10));

      // Calculate monthly stats
      _calculateMonthlyStats();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateMonthlyStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyTxs = HiveService.transactions.values
        .where(
          (tx) =>
              tx.userId == currentUser.value?.id &&
              tx.date.isAfter(startOfMonth) &&
              tx.date.isBefore(endOfMonth.add(const Duration(days: 1))),
        )
        .toList();

    double income = 0.0;
    double expenses = 0.0;

    for (final tx in monthlyTxs) {
      if (tx.affectsBalance) {
        if (tx.type == TransactionType.income) {
          income += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          expenses += tx.amount;
        }
      }
    }

    monthlyIncome.value = income;
    monthlyExpenses.value = expenses;
  }

  void navigateToTransactions() {
    Get.toNamed(Routes.transactions);
  }

  void navigateToAddTransaction() {
    Get.toNamed('${Routes.transactions}/add');
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    final name = currentUser.value?.name.split(' ').first ?? 'Utilisateur';

    if (hour < 12) {
      return 'Bonjour, $name';
    } else if (hour < 17) {
      return 'Bon après-midi, $name';
    } else {
      return 'Bonsoir, $name';
    }
  }

  double get savingsRate {
    if (monthlyIncome.value == 0) return 0.0;
    final savings = monthlyIncome.value - monthlyExpenses.value;
    return (savings / monthlyIncome.value) * 100;
  }
}
