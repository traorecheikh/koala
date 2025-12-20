import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:uuid/uuid.dart';

class DebtController extends GetxController {
  RxList<Debt> get debts => _financialContextService.allDebts;
  final selectedTab = 0.obs;

  late FinancialContextService _financialContextService;
  late FinancialEventsService _financialEventsService;
  final List<Worker> _workers = []; // List to store workers for disposal

  @override
  void onInit() {
    super.onInit();
    _financialContextService = Get.find<FinancialContextService>();
    _financialEventsService = Get.find<FinancialEventsService>();
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  Future<void> addDebt({
    required String personName,
    required double amount,
    required DebtType type,
    DateTime? dueDate,
    double? minPayment,
  }) async {

    final debtId = const Uuid().v4();
    final debt = Debt(
      id: debtId,
      personName: personName,
      originalAmount: amount,
      remainingAmount: amount,
      type: type,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      minPayment: minPayment ?? 0.0,
    );

    // Create transaction to reflect the money movement
    // Borrowed: I received money (income)
    // Lent: I gave money (expense)
    final tx = LocalTransaction.create(
      amount: amount,
      description: type == DebtType.borrowed
          ? 'Emprunt: $personName'
          : 'Prêt: $personName',
      date: DateTime.now(),
      type: type == DebtType.borrowed
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: null,
      linkedDebtId: debtId,
    );

    // Save debt to Isar
    IsarService.addDebt(debt);

    // Save transaction to ISAR (Source of Truth for Balance)
    IsarService.addTransaction(tx);

    // Emit transaction event to update balance (might be redundant if Isar watch works, but harmless)
    _financialEventsService.emitTransactionAdded(tx);
  }

  Future<void> updateDebt(Debt updatedDebt) async {
    IsarService.updateDebt(updatedDebt);
    int index = debts.indexWhere((d) => d.id == updatedDebt.id);
    if (index != -1) {
      debts[index] = updatedDebt;
    }
  }

  Future<void> deleteDebt(String debtId) async {
    await IsarService.deleteDebt(debtId);
    debts.removeWhere((debt) => debt.id == debtId);
  }

  Future<void> recordRepayment(Debt debt, double amount) async {
    // 1. Create transaction
    final tx = LocalTransaction.create(
      amount: amount,
      description: 'Remboursement: ${debt.personName}',
      date: DateTime.now(),
      type: debt.type == DebtType.lent
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: null, // Could be 'Debt' category if added
      linkedDebtId: debt.id, // Link transaction to debt
    );

    // Save to ISAR
    IsarService.addTransaction(tx);

    // 2. Update Debt
    debt.remainingAmount -= amount;
    if (debt.remainingAmount < 0) debt.remainingAmount = 0;
    // Add transaction ID to debt's transactionIds list
    final updatedDebt =
        debt.copyWith(transactionIds: [...debt.transactionIds, tx.id]);
    await updateDebt(updatedDebt);

    // 3. Emit events
    _financialEventsService
        .emit(TransactionEvent(FinancialEventType.transactionAdded, tx));
    if (updatedDebt.remainingAmount <= 0) {
      _financialEventsService.emitDebtPaidOff(updatedDebt);
    }
  }

  // --- New Methods for Enhanced Integration ---

  // Total debt, monthly obligations, projected payoff date
  Map<String, dynamic> getDebtImpact() {
    final totalOutstandingDebt =
        _financialContextService.totalOutstandingDebt.value;
    final totalMonthlyDebtPayments =
        _financialContextService.totalMonthlyDebtPayments.value;

    DateTime? projectedPayoffDate;
    if (totalOutstandingDebt > 0 && totalMonthlyDebtPayments > 0) {
      // Simple approximation: assuming current monthly payments continue
      final monthsToPayoff = totalOutstandingDebt / totalMonthlyDebtPayments;
      projectedPayoffDate =
          DateTime.now().add(Duration(days: (monthsToPayoff * 30).round()));
    }

    return {
      'totalOutstandingDebt': totalOutstandingDebt,
      'totalMonthlyDebtPayments': totalMonthlyDebtPayments,
      'projectedPayoffDate': projectedPayoffDate,
    };
  }

  // Auto-create goal for debt payoff
  Future<void> createPayoffGoal(Debt debt) async {
    final goalsController = Get.find<GoalsController>();
    final newGoal = FinancialGoal.create(
      title: 'Rembourser ${debt.personName}',
      description: 'Rembourser la dette de ${debt.personName}',
      targetAmount: debt.remainingAmount,
      type: GoalType.debtPayoff,
      linkedDebtId: debt.id,
    );
    await goalsController.addGoal(newGoal);
    _financialEventsService.emit(GoalEvent(
        FinancialEventType.goalMilestoneReached,
        newGoal)); // Assuming goal creation is a milestone
  }

  // Use simulator for payoff scenarios (placeholder for now, actual simulation logic in SimulatorEngine)
  Map<String, dynamic> simulatePayoff(String debtId, double monthlyPayment) {
    final debt = _financialContextService.getDebtById(debtId);
    if (debt == null || monthlyPayment <= 0) {
      return {'error': 'Dette non trouvée ou paiement mensuel invalide.'};
    }

    double currentRemaining = debt.remainingAmount;
    int months = 0;
    while (currentRemaining > 0 && months < 1200) {
      // Max 100 years to prevent infinite loop
      currentRemaining -= monthlyPayment;
      months++;
    }

    final projectedPayoffDate = DateTime.now()
        .add(Duration(days: (months * 30).round())); // Approximate
    // A more accurate simulation would factor in interest and actual payment schedule

    return {
      'monthsToPayoff': months,
      'projectedPayoffDate': projectedPayoffDate,
      'totalAmountPaid':
          debt.originalAmount, // Simplified, doesn't include future interest
      // 'interestSavings': calculateInterestSavings(), // Requires interest rate and original payment plan
    };
  }

  // Debt payoff timeline with different payment strategies
  // List<DebtPayoffEvent> getPayoffTimeline(Debt debt, double extraPayment) { ... }

  // Interest savings calculations
  // double calculateInterestSavings(Debt debt, double newMonthlyPayment) { ... }
}
