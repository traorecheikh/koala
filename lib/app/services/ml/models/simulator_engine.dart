import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/services/financial_context_service.dart'; // New import
import 'package:koaa/app/services/ml/models/time_series_engine.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For min/max
import 'package:logger/logger.dart';

enum ScenarioType {
  normal,
  delayPurchase,
  adjustGoalContribution,
  extraDebtPayment,
  // Add more as needed
}

class SimulationScenario {
  final ScenarioType type;
  final double? purchaseAmount; // For simulatePurchase or scenario impact
  final Duration? delayDuration; // For delayPurchase
  final String? goalIdToAdjust;
  final double? newGoalContribution;
  final String? debtIdToAdjust;
  final double? extraDebtPayment;

  SimulationScenario({
    this.type = ScenarioType.normal,
    this.purchaseAmount,
    this.delayDuration,
    this.goalIdToAdjust,
    this.newGoalContribution,
    this.debtIdToAdjust,
    this.extraDebtPayment,
  });

  SimulationScenario copyWith({
    ScenarioType? type,
    double? purchaseAmount,
    Duration? delayDuration,
    String? goalIdToAdjust,
    double? newGoalContribution,
    String? debtIdToAdjust,
    double? extraDebtPayment,
  }) {
    return SimulationScenario(
      type: type ?? this.type,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      delayDuration: delayDuration ?? this.delayDuration,
      goalIdToAdjust: goalIdToAdjust ?? this.goalIdToAdjust,
      newGoalContribution: newGoalContribution ?? this.newGoalContribution,
      debtIdToAdjust: debtIdToAdjust ?? this.debtIdToAdjust,
      extraDebtPayment: extraDebtPayment ?? this.extraDebtPayment,
    );
  }
}

class SimulationReport {
  final double initialBalance;
  final double finalBalance;
  final List<CashFlowEvent> cashFlowTimeline;
  final bool isSolvent;
  final double lowestBalance;
  final DateTime? firstNegativeBalanceDate;
  final Map<String, double> goalProgressImpact; // Goal ID -> new progress
  final Map<String, double> budgetImpact; // Budget Category ID -> new spent amount
  final String summary;

  SimulationReport({
    required this.initialBalance,
    required this.finalBalance,
    required this.cashFlowTimeline,
    required this.isSolvent,
    required this.lowestBalance,
    this.firstNegativeBalanceDate,
    this.goalProgressImpact = const {},
    this.budgetImpact = const {},
    required this.summary,
  });
}

class CashFlowEvent {
  final DateTime date;
  final String description;
  final double amount; // Positive for inflow, negative for outflow
  final double balanceAfterEvent;
  final String? categoryId; // Optional: Link to category

  CashFlowEvent({
    required this.date,
    required this.description,
    required this.amount,
    required this.balanceAfterEvent,
    this.categoryId,
  });
}

class SimulatorEngine {
  final TimeSeriesEngine _timeSeriesEngine;
  final FinancialContextService _financialContextService; // Injected
  final _logger = Logger();

  SimulatorEngine(this._timeSeriesEngine, this._financialContextService);

  /// Simulate cash flow over a period, considering all financial contexts.
  SimulationReport simulateWithContext({
    required int daysToSimulate,
    SimulationScenario? scenario,
  }) {
    _logger.d('Starting Simulation: $daysToSimulate days');

    // Deep copy current state from FinancialContextService to allow scenario modifications
    double currentBalance = _financialContextService.currentBalance.value;
    
    _logger.d('Initial Balance: $currentBalance');

    final List<Job> jobs = List.from(_financialContextService.allJobs);
    final List<RecurringTransaction> recurringTransactions =
        List.from(_financialContextService.allRecurringTransactions);
    final List<Debt> debts = _financialContextService.allDebts.map((d) => d.copyWith()).toList(); // Copy to allow modification
    final List<FinancialGoal> goals = _financialContextService.allGoals.map((g) => g.copyWith()).toList(); // Copy to allow modification
    final List<Budget> budgets = _financialContextService.allBudgets.map((b) => b.copyWith()).toList(); // Copy to allow modification
    
    // Initial conditions
    final DateTime simulationStartDate = DateTime.now();
    double lowestBalance = currentBalance;
    DateTime? firstNegativeBalanceDate;
    final List<CashFlowEvent> timeline = [];
    String summary = 'Simulation completed.';

    // Initialize budget and goal impacts
    final Map<String, double> simulatedBudgetSpent = {};
    for (var budget in budgets) {
      simulatedBudgetSpent[budget.categoryId] = _financialContextService.getSpentAmountForCategory(
        budget.categoryId, budget.year, budget.month);
    }
    final Map<String, double> simulatedGoalProgress = {};
    for (var goal in goals) {
      simulatedGoalProgress[goal.id] = goal.currentAmount;
    }


    // Apply scenario modifications
    if (scenario != null) {
      if (scenario.purchaseAmount != null) {
        currentBalance -= scenario.purchaseAmount!;
        timeline.add(CashFlowEvent(
          date: simulationStartDate,
          description: 'Achat simulé',
          amount: -scenario.purchaseAmount!,
          balanceAfterEvent: currentBalance,
        ));
      }
      if (scenario.type == ScenarioType.delayPurchase && scenario.delayDuration != null) {
        // For delay purchase, the purchase event is added later in the timeline
      }
      if (scenario.type == ScenarioType.adjustGoalContribution && scenario.goalIdToAdjust != null && scenario.newGoalContribution != null) {
        final goalIndex = goals.indexWhere((g) => g.id == scenario.goalIdToAdjust);
        if (goalIndex != -1) {
          // This is a simplified adjustment. A real implementation would adjust the recurring contribution amount
          // and re-simulate the goal's progress. For now, we'll note the change.
          summary += ' La contribution à l\'objectif "${goals[goalIndex].title}" est ajustée à ${scenario.newGoalContribution} FCFA.';
        }
      }
      if (scenario.type == ScenarioType.extraDebtPayment && scenario.debtIdToAdjust != null && scenario.extraDebtPayment != null) {
        final debtIndex = debts.indexWhere((d) => d.id == scenario.debtIdToAdjust);
        if (debtIndex != -1) {
          // Apply extra payment immediately to the debt for simulation purposes
          final extraPayment = min(scenario.extraDebtPayment!, debts[debtIndex].remainingAmount);
          debts[debtIndex].remainingAmount -= extraPayment;
          currentBalance -= extraPayment;
          timeline.add(CashFlowEvent(
            date: simulationStartDate,
            description: 'Paiement supplémentaire de la dette (${debts[debtIndex].personName})',
            amount: -extraPayment,
            balanceAfterEvent: currentBalance,
          ));
          summary += ' Un paiement supplémentaire de ${extraPayment} FCFA a été effectué sur la dette "${debts[debtIndex].personName}".';
        }
      }
    }

    // Calculate daily average organic spending (burn rate) from recent history
    // We use the last 90 days of history for a robust average
    final recentHistory = _financialContextService.allTransactions.where((t) => 
      t.date.isAfter(DateTime.now().subtract(const Duration(days: 90)))).toList();
    
    // Calculate history window based on OLDEST transaction in the system
    final globalFirstTx = _financialContextService.allTransactions.isEmpty 
        ? DateTime.now() 
        : _financialContextService.allTransactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final daysSinceStart = DateTime.now().difference(globalFirstTx).inDays + 1;
    // Enforce minimum 30 days window to avoid "New User Spike" bias
    final historyWindow = min(max(daysSinceStart, 30), 90);

    final dailyBurnRate = _calculateDailyBurnRate(recentHistory, recurringTransactions, historyWindow);
    _logger.i('Calculated Daily Burn Rate: $dailyBurnRate');

    // Daily simulation loop
    for (int i = 0; i < daysToSimulate; i++) {
      final currentDate = simulationStartDate.add(Duration(days: i));
      
      // Apply daily burn rate (distributed organic spending)
      currentBalance -= dailyBurnRate;

      // Check for delayed purchase event
      if (scenario?.type == ScenarioType.delayPurchase && scenario?.purchaseAmount != null && scenario!.delayDuration != null) {
        if (currentDate.isAtSameMomentAs(simulationStartDate.add(scenario.delayDuration!)) ||
            (currentDate.isAfter(simulationStartDate.add(scenario.delayDuration!)) &&
             simulationStartDate.add(scenario.delayDuration!).day == currentDate.day &&
             simulationStartDate.add(scenario.delayDuration!).month == currentDate.month &&
             simulationStartDate.add(scenario.delayDuration!).year == currentDate.year)) {
          currentBalance -= scenario.purchaseAmount!;
          timeline.add(CashFlowEvent(
            date: currentDate,
            description: 'Achat simulé (retardé)',
            amount: -scenario.purchaseAmount!,
            balanceAfterEvent: currentBalance,
          ));
        }
      }

      // Income from jobs
      for (final job in jobs) {
        if (job.isPaymentDue(currentDate)) {
          currentBalance += job.amount;
          timeline.add(CashFlowEvent(
            date: currentDate,
            description: 'Salaire (${job.name})',
            amount: job.amount,
            balanceAfterEvent: currentBalance,
          ));
        }
      }

      // Recurring expenses
      for (final rt in recurringTransactions) {
        if (rt.isDue(currentDate)) {
          currentBalance -= rt.amount;
          timeline.add(CashFlowEvent(
            date: currentDate,
            description: 'Dépense récurrente (${rt.description})',
            amount: -rt.amount,
            balanceAfterEvent: currentBalance,
            categoryId: rt.categoryId,
          ));
          // Update simulated budget spent
          if (rt.categoryId != null && simulatedBudgetSpent.containsKey(rt.categoryId)) {
            final categoryId = rt.categoryId!;
            simulatedBudgetSpent[categoryId] = (simulatedBudgetSpent[categoryId] ?? 0) + rt.amount;
          }
        }
      }

      // Debt payments (assuming monthly payments on specific day)
      for (final debt in debts) {
        if (!debt.isPaidOff && debt.minPayment > 0 && currentDate.day == debt.createdAt.day) { // Assuming payment on creation day
          final payment = min(debt.minPayment, debt.remainingAmount);
          currentBalance -= payment;
          debt.remainingAmount -= payment;
          timeline.add(CashFlowEvent(
            date: currentDate,
            description: 'Paiement de dette (${debt.personName})',
            amount: -payment,
            balanceAfterEvent: currentBalance,
          ));
        }
      }

      // Goal contributions (simplified: assuming a fixed monthly contribution amount is saved towards active goals)
      // This needs more robust integration with how users actually contribute to goals.
      for (final goal in goals) {
        if (goal.status == GoalStatus.active && goal.targetAmount > goal.currentAmount) {
          // For simplicity, let's assume a portion of monthly income goes to goals
          // A better approach would be user-defined recurring contributions to goals
          // Or automatic allocation from "savings" budget categories.
          // For this simulation, we'll just track if goals are met by available funds.
          // This part of simulation needs real financial logic of how a user save or invest for goal.
        }
      }

      // Track lowest balance and first negative date
      if (currentBalance < lowestBalance) {
        lowestBalance = currentBalance;
      }
      if (currentBalance < 0 && firstNegativeBalanceDate == null) {
        firstNegativeBalanceDate = currentDate;
      }
    }

    bool isSolvent = lowestBalance >= 0;
    if (!isSolvent) {
      summary = 'La simulation prévoit que vous pourriez être à découvert.';
    } else {
      summary = 'La simulation montre que vous devriez rester solvable.';
    }
    
    _logger.i('Simulation Ended. Final: $currentBalance. Solvent: $isSolvent. Lowest: $lowestBalance');

    // Final check for goal progress and budget impact after simulation
    for (var goal in goals) {
      simulatedGoalProgress[goal.id] = goal.currentAmount; // This needs to be updated by actual simulation logic
    }

    return SimulationReport(
      initialBalance: _financialContextService.currentBalance.value,
      finalBalance: currentBalance,
      cashFlowTimeline: timeline,
      isSolvent: isSolvent,
      lowestBalance: lowestBalance,
      firstNegativeBalanceDate: firstNegativeBalanceDate,
      summary: summary,
      goalProgressImpact: simulatedGoalProgress,
      budgetImpact: simulatedBudgetSpent,
    );
  }

  /// Simulate cash flow impact of a proposed expense
  SimulationResult simulatePurchase({
    required double currentBalance,
    required double purchaseAmount,
    required List<RecurringTransaction> recurringBills,
    required List<LocalTransaction> recentHistory,
    int daysToSimulate = 30,
  }) {
    _logger.d('Simulating Purchase: $purchaseAmount for $daysToSimulate days');
    
    double simulatedBalance = currentBalance - purchaseAmount;
    final now = DateTime.now();
    DateTime? zeroBalanceDate;
    double lowestBalance = simulatedBalance;
    String? reasonForRisk;
    double initialBalanceAfterPurchase = simulatedBalance;

    // Calculate daily average organic spending (excluding large recurring bills)
    final globalFirstTx = _financialContextService.allTransactions.isEmpty 
        ? DateTime.now() 
        : _financialContextService.allTransactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final daysSinceStart = DateTime.now().difference(globalFirstTx).inDays + 1;
    // Enforce minimum 30 days window
    final historyWindow = min(max(daysSinceStart, 30), 90);

    double dailyBurnRate = _calculateDailyBurnRate(recentHistory, recurringBills, historyWindow);
    _logger.i('Purchase Sim Burn Rate: $dailyBurnRate');

    for (int i = 1; i <= daysToSimulate; i++) {
      final date = now.add(Duration(days: i));
      
      // Subtract organic spending
      simulatedBalance -= dailyBurnRate;

      // Add expected income
      for (final job in _financialContextService.allJobs) {
        if (job.isPaymentDue(date)) {
          simulatedBalance += job.amount;
        }
      }

      // Subtract recurring bills due on this day
      for (final bill in recurringBills) {
        if (_isBillDueOn(bill, date)) {
          simulatedBalance -= bill.amount;
          if (simulatedBalance <= 0 && reasonForRisk == null) {
            reasonForRisk = 'Le paiement de la facture "${bill.description}"';
          }
        }
      }

      // Track lowest balance and first zero balance date
      if (simulatedBalance < lowestBalance) {
        lowestBalance = simulatedBalance;
      }
      if (simulatedBalance <= 0 && zeroBalanceDate == null) {
        zeroBalanceDate = date;
      }
    }

    final isSafe = lowestBalance >= 0;
    
    // Determine the actual margin/deficit
    double finalMargin = lowestBalance;
    if (lowestBalance < 0 && reasonForRisk == null) {
        reasonForRisk = 'Dépenses quotidiennes';
    }

    // Identify upcoming bills in the simulation window
    final upcomingBills = recurringBills.where((bill) {
      for (int i = 1; i <= daysToSimulate; i++) {
        if (_isBillDueOn(bill, now.add(Duration(days: i)))) return true;
      }
      return false;
    }).toList();

    return SimulationResult(
      isSafe: isSafe,
      lowestBalance: lowestBalance,
      daysUntilBroke: zeroBalanceDate != null ? zeroBalanceDate.difference(now).inDays : null,
      surplus: isSafe ? finalMargin : 0,
      deficit: !isSafe ? finalMargin.abs() : 0,
      dailyBurnRate: dailyBurnRate,
      upcomingBills: upcomingBills,
      explanation: SimulationExplanation(
        mainImpact: isSafe 
            ? 'Vous pouvez effectuer cet achat en toute sécurité.'
            : 'Cet achat risque de vous mettre en difficulté financière.',
        details: isSafe
            ? 'Après avoir effectué l\'achat, votre solde ne descendra pas en dessous de ${NumberFormat.compact().format(lowestBalance)} F sur les 30 prochains jours.'
            : '${reasonForRisk ?? "Vos dépenses"} risquent de vous faire passer à découvert. Votre solde pourrait devenir négatif dans les 30 prochains jours.',
        criticalPoint: !isSafe && zeroBalanceDate != null
            ? 'Vous pourriez atteindre un solde nul ou négatif aux alentours du ${DateFormat('dd MMM').format(zeroBalanceDate)}.'
            : null,
      ),
    );
  }

  double _calculateDailyBurnRate(List<LocalTransaction> history, List<RecurringTransaction> bills, int windowDays) {
    if (history.isEmpty) return 0;

    // Filter for expenses, exclude amounts close to known recurring bills
    final nonBillExpenses = history.where((t) {
      if (t.type != TransactionType.expense) return false;
      // Check if this transaction is likely a recurring bill
      return !bills.any((bill) => (t.amount - bill.amount).abs() < t.amount * 0.1 && // Amount is similar
                                   t.date.difference(bill.lastGeneratedDate).inDays.abs() < 10); // Around bill date
    }).toList();
    
    if (nonBillExpenses.isEmpty) return 0;

    final totalNonBillSpend = nonBillExpenses.fold(0.0, (sum, t) => sum + t.amount);
    
    // Use the provided window (days since start or 90), ensuring at least 1 day
    return totalNonBillSpend / (windowDays > 0 ? windowDays : 1);
  }

  bool _isBillDueOn(RecurringTransaction bill, DateTime date) {
    if (bill.frequency == Frequency.monthly) {
      return date.day == bill.dayOfMonth;
    }
    // TODO: Handle weekly bills properly
    return false;
  }
}

class SimulationResult {
  final bool isSafe;
  final double lowestBalance;
  final int? daysUntilBroke;
  final double surplus;
  final double deficit;
  final double dailyBurnRate;
  final List<RecurringTransaction> upcomingBills;
  final SimulationExplanation explanation;

  SimulationResult({
    required this.isSafe,
    required this.lowestBalance,
    this.daysUntilBroke,
    required this.surplus,
    required this.deficit,
    required this.dailyBurnRate,
    required this.upcomingBills,
    required this.explanation,
  });
}

class SimulationExplanation {
  final String mainImpact;
  final String details;
  final String? criticalPoint;

  SimulationExplanation({
    required this.mainImpact,
    required this.details,
    this.criticalPoint,
  });
}
