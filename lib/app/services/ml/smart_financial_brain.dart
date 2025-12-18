import 'package:get/get.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/ml/financial_intelligence.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:logger/logger.dart';
import 'dart:math';

/// The Smart Financial Brain - Central intelligence for all financial insights
/// This is the core AI/ML engine that powers all smart features in the app
class SmartFinancialBrain extends GetxService {
  final _logger = Logger();
  late FinancialContextService _context;

  // Reactive intelligence outputs
  final Rx<FinancialIntelligence> intelligence =
      FinancialIntelligence.empty().obs;

  @override
  void onInit() {
    super.onInit();
    _context = Get.find<FinancialContextService>();

    // React to any financial change with DEBOUNCE to avoid UI jank during rapid updates
    debounce(_context.allTransactions, (_) => _recalculate(),
        time: const Duration(milliseconds: 500));
    debounce(_context.allDebts, (_) => _recalculate(),
        time: const Duration(milliseconds: 500));
    debounce(_context.allGoals, (_) => _recalculate(),
        time: const Duration(milliseconds: 500));
    debounce(_context.allBudgets, (_) => _recalculate(),
        time: const Duration(milliseconds: 500));
    debounce(_context.currentBalance, (_) => _recalculate(),
        time: const Duration(milliseconds: 500));

    // Delay initial calculation to allow UI to render first
    Future.delayed(const Duration(milliseconds: 800), _recalculate);
  }

  Future<void> _recalculate() async {
    _logger.d('SmartFinancialBrain: Recalculating intelligence...');

    // Yield to UI thread before starting heavy work
    await Future.delayed(Duration.zero);

    final transactions = _context.allTransactions.toList();
    final debts = _context.allDebts.toList();
    final goals = _context.allGoals.toList();
    final budgets = _context.allBudgets.toList();
    final balance = _context.currentBalance.value;
    final monthlyIncome = _context.totalMonthlyIncome.value;

    intelligence.value = FinancialIntelligence(
      // Core metrics
      spendingBehavior: _analyzeSpendingBehavior(transactions, monthlyIncome),
      debtStrategy: _analyzeDebtStrategy(debts, monthlyIncome, balance),
      goalProgress: _analyzeGoalProgress(goals, monthlyIncome, balance),
      budgetHealth: _analyzeBudgetHealth(budgets, transactions),
      cashFlowPrediction:
          _predictCashFlow(transactions, debts, monthlyIncome, balance),
      netWorthAnalysis: _calculateNetWorth(balance, debts, goals),

      // Smart recommendations
      recommendations: _generateRecommendations(
        transactions,
        debts,
        goals,
        budgets,
        balance,
        monthlyIncome,
      ),

      // Risk assessment
      overallRiskLevel: _calculateOverallRisk(
        transactions,
        debts,
        goals,
        balance,
        monthlyIncome,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPENDING BEHAVIOR ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════════

  SpendingBehavior _analyzeSpendingBehavior(
      List<LocalTransaction> transactions, double monthlyIncome) {
    if (transactions.isEmpty || monthlyIncome <= 0) {
      return SpendingBehavior.empty();
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final dayOfMonth = now.day;

    // This month's expenses (include first day of month!)
    final thisMonthExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense && !t.date.isBefore(monthStart))
        .toList();

    final totalSpentThisMonth =
        thisMonthExpenses.fold(0.0, (sum, t) => sum + t.amount);

    // Spending velocity (how fast you're spending)
    // Formula: (Spent / DaysPassed) * DaysInMonth = Projected
    // Ratio: Projected / Income
    final avgDailySpending =
        totalSpentThisMonth / (dayOfMonth > 0 ? dayOfMonth : 1);
    final projectedSpending = avgDailySpending * daysInMonth;

    // Improved Velocity Ratio: Projected Spending / Total Income
    final velocityRatio =
        projectedSpending / (monthlyIncome > 0 ? monthlyIncome : 1);

    // Largest single transaction
    final largestTransaction = thisMonthExpenses.isNotEmpty
        ? thisMonthExpenses.reduce((a, b) => a.amount > b.amount ? a : b)
        : null;

    // Impulsive spending detection (large transactions > 20% of income)
    final impulsiveTransactions = thisMonthExpenses
        .where((t) => t.amount > monthlyIncome * 0.20)
        .toList();

    // Daily spending pattern
    final Map<int, double> dailySpending = {};
    for (final t in thisMonthExpenses) {
      final day = t.date.day;
      dailySpending[day] = (dailySpending[day] ?? 0) + t.amount;
    }

    // Find spending spikes (days where spending > 3x average)
    final spikeDays = dailySpending.entries
        .where((e) => e.value > avgDailySpending * 3)
        .map((e) => e.key)
        .toList();

    // Category breakdown
    final Map<String, double> categorySpending = {};
    for (final t in thisMonthExpenses) {
      final category = t.categoryId ?? 'other';
      categorySpending[category] = (categorySpending[category] ?? 0) + t.amount;
    }

    // Top spending category
    String? topCategory;
    double topAmount = 0;
    categorySpending.forEach((cat, amount) {
      if (amount > topAmount) {
        topAmount = amount;
        topCategory = cat;
      }
    });

    // Spending pattern type based on corrected velocity
    SpendingPattern pattern;
    if (velocityRatio > 1.2) {
      // Projected to spend 120% of income
      pattern = SpendingPattern.reckless;
    } else if (velocityRatio > 1.05) {
      // Projected to slightly exceed income
      pattern = SpendingPattern.aggressive;
    } else if (velocityRatio > 0.95) {
      // Living paycheck to paycheck
      pattern = SpendingPattern.atRisk;
    } else if (velocityRatio > 0.8) {
      // Healthy margin (saving ~20%)
      pattern = SpendingPattern.balanced;
    } else {
      // Saving >20%
      pattern = SpendingPattern.conservative;
    }

    return SpendingBehavior(
      totalSpentThisMonth: totalSpentThisMonth,
      velocityRatio: velocityRatio,
      pattern: pattern,
      avgDailySpending: avgDailySpending,
      impulsiveTransactionCount: impulsiveTransactions.length,
      largestTransaction: largestTransaction,
      spikeDays: spikeDays,
      topSpendingCategory: topCategory,
      categoryBreakdown: categorySpending,
      daysUntilMonthEnd: daysInMonth - dayOfMonth,
      projectedMonthEndSpending: projectedSpending,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBT STRATEGY ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════════

  DebtStrategy _analyzeDebtStrategy(
      List<Debt> debts, double monthlyIncome, double balance) {
    if (debts.isEmpty) {
      return DebtStrategy.empty();
    }

    final activeDebts = debts.where((d) => !d.isPaidOff).toList();
    final totalDebt =
        activeDebts.fold(0.0, (sum, d) => sum + d.remainingAmount);
    final totalMonthlyPayments =
        activeDebts.fold(0.0, (sum, d) => sum + d.minPayment);

    // Debt-to-Income ratio
    final dtiRatio = monthlyIncome > 0 ? totalDebt / (monthlyIncome * 12) : 0;

    // Monthly payment burden
    final paymentBurden =
        monthlyIncome > 0 ? totalMonthlyPayments / monthlyIncome : 0;

    // Debts at risk (can't afford minimum payment)
    final debtsAtRisk =
        activeDebts.where((d) => d.minPayment > balance * 0.5).toList();

    // Optimal payoff order (Avalanche: highest interest first, or Snowball: smallest balance first)
    // Since we don't have interest rates, we'll use Snowball (smallest first for quick wins)
    final snowballOrder = List<Debt>.from(activeDebts)
      ..sort((a, b) => a.remainingAmount.compareTo(b.remainingAmount));

    // Optimal strategy based on burden
    PayoffStrategy optimalStrategy;
    if (paymentBurden > 0.50) {
      optimalStrategy =
          PayoffStrategy.seekHelp; // >50% of income on debt payments
    } else if (paymentBurden > 0.35) {
      optimalStrategy = PayoffStrategy.aggressive; // Prioritize debt payoff
    } else if (paymentBurden > 0.20) {
      optimalStrategy = PayoffStrategy.balanced; // Balance debt and savings
    } else {
      optimalStrategy = PayoffStrategy.comfortable; // Low burden, can save more
    }

    // Estimate payoff time (months) for total debt at current payment rate
    final monthsToPayoff = totalMonthlyPayments > 0
        ? (totalDebt / totalMonthlyPayments).ceil()
        : 999;

    // Find the debt to prioritize (smallest for quick wins)
    final priorityDebt = snowballOrder.isNotEmpty ? snowballOrder.first : null;

    return DebtStrategy(
      totalDebt: totalDebt,
      totalMonthlyPayments: totalMonthlyPayments,
      debtToIncomeRatio: dtiRatio.toDouble(),
      paymentBurden: paymentBurden.toDouble(),
      activeDebtCount: activeDebts.length,
      debtsAtRisk: debtsAtRisk,
      optimalPayoffOrder: snowballOrder,
      recommendedStrategy: optimalStrategy,
      estimatedMonthsToDebtFree: monthsToPayoff,
      priorityDebt: priorityDebt,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOAL PROGRESS ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════════

  GoalProgressAnalysis _analyzeGoalProgress(
      List<FinancialGoal> goals, double monthlyIncome, double balance) {
    if (goals.isEmpty) {
      return GoalProgressAnalysis.empty();
    }

    final activeGoals =
        goals.where((g) => g.status == GoalStatus.active).toList();
    final totalTarget = activeGoals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final totalSaved = activeGoals.fold(0.0, (sum, g) => sum + g.currentAmount);

    // Calculate monthly savings capacity (assume 20% of income can go to savings)
    final monthlySavingsCapacity = monthlyIncome * 0.20;

    // For each goal, calculate feasibility
    final List<GoalInsight> goalInsights = [];
    for (final goal in activeGoals) {
      final remaining = goal.targetAmount - goal.currentAmount;
      final progressPercent =
          goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0;

      // Calculate months needed at current savings rate
      int? monthsNeeded;
      if (monthlySavingsCapacity > 0) {
        // Distribute savings capacity across all goals equally
        final perGoalMonthly = monthlySavingsCapacity / activeGoals.length;
        monthsNeeded = (remaining / perGoalMonthly).ceil();
      }

      // Check if on track for deadline
      bool onTrack = true;
      int? monthsBehind;
      if (goal.targetDate != null) {
        final monthsUntilDeadline =
            goal.targetDate!.difference(DateTime.now()).inDays ~/ 30;
        if (monthsNeeded != null && monthsNeeded > monthsUntilDeadline) {
          onTrack = false;
          monthsBehind = monthsNeeded - monthsUntilDeadline;
        }
      }

      // Calculate recommended monthly contribution
      double? recommendedContribution;
      if (goal.targetDate != null) {
        final monthsUntilDeadline =
            max(1, goal.targetDate!.difference(DateTime.now()).inDays ~/ 30);
        recommendedContribution = remaining / monthsUntilDeadline;
      }

      goalInsights.add(GoalInsight(
        goal: goal,
        progressPercent: progressPercent.toDouble(),
        remainingAmount: remaining,
        estimatedMonthsToComplete: monthsNeeded,
        isOnTrack: onTrack,
        monthsBehindSchedule: monthsBehind,
        recommendedMonthlyContribution: recommendedContribution,
      ));
    }

    // Sort by priority: off-track goals first, then by closest deadline
    goalInsights.sort((a, b) {
      if (a.isOnTrack != b.isOnTrack) {
        return a.isOnTrack ? 1 : -1; // Off-track first
      }
      if (a.goal.targetDate != null && b.goal.targetDate != null) {
        return a.goal.targetDate!.compareTo(b.goal.targetDate!);
      }
      return 0;
    });

    return GoalProgressAnalysis(
      totalTargetAmount: totalTarget,
      totalSavedAmount: totalSaved,
      overallProgress: totalTarget > 0 ? totalSaved / totalTarget : 0,
      activeGoalCount: activeGoals.length,
      goalsOnTrack: goalInsights.where((g) => g.isOnTrack).length,
      goalsAtRisk: goalInsights.where((g) => !g.isOnTrack).length,
      goalInsights: goalInsights,
      monthlySavingsCapacity: monthlySavingsCapacity,
      priorityGoal: goalInsights.isNotEmpty ? goalInsights.first : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUDGET HEALTH ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════════

  BudgetHealth _analyzeBudgetHealth(
      List<Budget> budgets, List<LocalTransaction> transactions) {
    if (budgets.isEmpty) {
      return BudgetHealth.empty();
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final dayOfMonth = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthProgress = dayOfMonth / daysInMonth;

    final List<BudgetInsight> insights = [];
    int exceededCount = 0;
    int atRiskCount = 0;
    int healthyCount = 0;

    for (final budget in budgets) {
      // Get spending for this budget's category this month
      final categorySpending = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.categoryId == budget.categoryId &&
              t.date.isAfter(monthStart) &&
              !t.isCatchUp) // Skip catch-up transactions
          .fold(0.0, (sum, t) => sum + t.amount);

      final usagePercent =
          budget.amount > 0 ? categorySpending / budget.amount : 0;
      final expectedUsage =
          monthProgress; // Expected usage based on month progress

      BudgetStatus status;
      if (usagePercent >= 1.0) {
        status = BudgetStatus.exceeded;
        exceededCount++;
      } else if (usagePercent > expectedUsage + 0.20) {
        status = BudgetStatus.atRisk;
        atRiskCount++;
      } else if (usagePercent > expectedUsage - 0.10) {
        status = BudgetStatus.onTrack;
        healthyCount++;
      } else {
        status = BudgetStatus.underBudget;
        healthyCount++;
      }

      // Calculate daily allowance for remaining days
      final remainingBudget = budget.amount - categorySpending;
      final remainingDays = daysInMonth - dayOfMonth;
      final dailyAllowance =
          remainingDays > 0 ? remainingBudget / remainingDays : 0;

      insights.add(BudgetInsight(
        budget: budget,
        spent: categorySpending,
        usagePercent: usagePercent.toDouble(),
        status: status,
        remainingAmount: remainingBudget,
        dailyAllowance: dailyAllowance.toDouble(),
        projectedMonthEnd:
            categorySpending + (categorySpending / dayOfMonth * remainingDays),
      ));
    }

    // Sort by severity
    insights.sort((a, b) => b.usagePercent.compareTo(a.usagePercent));

    return BudgetHealth(
      totalBudgets: budgets.length,
      exceededCount: exceededCount,
      atRiskCount: atRiskCount,
      healthyCount: healthyCount,
      budgetInsights: insights,
      worstBudget: insights.isNotEmpty ? insights.first : null,
      overallHealth: budgets.isNotEmpty
          ? (healthyCount / budgets.length * 100).round()
          : 100,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CASH FLOW PREDICTION
  // ═══════════════════════════════════════════════════════════════════════════

  CashFlowPrediction _predictCashFlow(
    List<LocalTransaction> transactions,
    List<Debt> debts,
    double monthlyIncome,
    double balance,
  ) {
    final now = DateTime.now();
    final dayOfMonth = now.day;
    final int daysRemaining = 30; // Rolling 30-day window

    // 1. Calculate Variable Daily Spending (Excluding Recurring/Fixed)
    final monthStart = DateTime(now.year, now.month, 1);

    // Filter out recurring transactions from the average calculation
    // to avoid double counting fixed costs
    final variableExpenses = transactions.where((t) =>
        t.type == TransactionType.expense &&
        !t.isRecurring && // Skip recurring (rent, subs)
        t.linkedDebtId == null && // Skip debt payments
        !t.date.isBefore(monthStart));

    final totalVariableSpent =
        variableExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final avgDailyVariableSpending =
        dayOfMonth > 0 ? totalVariableSpent / dayOfMonth : 0;

    // 2. Predict Remaining Variable Spending (For next 30 days)
    final predictedVariableSpending = avgDailyVariableSpending * daysRemaining;

    // 3. Detect Already-Processed Items (Consistency with SimulatorEngine)
    final allTxs = _context.allTransactions;

    // Pre-calculate last processed dates for Jobs and RTs
    final lastJobs = <String, DateTime>{};
    final lastRTs = <String, DateTime>{};

    for (var tx in allTxs) {
      if (tx.linkedJobId != null) {
        final last = lastJobs[tx.linkedJobId!];
        if (last == null || tx.date.isAfter(last)) {
          lastJobs[tx.linkedJobId!] = tx.date;
        }
      }
      if (tx.linkedRecurringId != null) {
        final last = lastRTs[tx.linkedRecurringId!];
        if (last == null || tx.date.isAfter(last)) {
          lastRTs[tx.linkedRecurringId!] = tx.date;
        }
      }
    }

    // 4. Calculate Upcoming Fixed Expenses (Recurring + Debts)
    double upcomingDebtPayments = 0.0;
    double upcomingDebtCollections = 0.0;

    for (var debt in debts) {
      if (debt.isPaidOff) continue;
      if (debt.type == DebtType.borrowed) {
        upcomingDebtPayments += debt.minPayment;
      } else {
        upcomingDebtCollections += debt.minPayment;
      }
    }

    // 4b. Recurring Expenses (with history check)
    final allRecurring = _context.allRecurringTransactions;
    double upcomingRecurringExpenses = 0.0;
    double upcomingRecurringIncome = 0.0;

    for (final recurring in allRecurring) {
      if (!recurring.isActive) continue;

      // Check if already done this month (simplified monthly check)
      if (recurring.frequency == Frequency.monthly) {
        final lastProcessed = lastRTs[recurring.id];
        final alreadyDone = lastProcessed != null &&
            lastProcessed.month == now.month &&
            lastProcessed.year == now.year;

        if (alreadyDone) continue;

        if (recurring.type == TransactionType.expense) {
          upcomingRecurringExpenses += recurring.amount;
        } else {
          upcomingRecurringIncome += recurring.amount;
        }
      } else {
        // For other frequencies, assume at least one occurrence in 30 days if not monthly
        // (Simplified for Brain summary, deep simulation handles daily/weekly better)
        if (recurring.type == TransactionType.expense) {
          upcomingRecurringExpenses += recurring.amount;
        } else {
          upcomingRecurringIncome += recurring.amount;
        }
      }
    }

    // 5. Calculate Upcoming Job Income
    double upcomingJobIncome = 0;
    for (final job in _context.allJobs) {
      if (!job.isActive) continue;

      final lastProcessed = lastJobs[job.id];
      final alreadyPaid = lastProcessed != null &&
          lastProcessed.month == now.month &&
          lastProcessed.year == now.year;

      if (alreadyPaid) continue;

      upcomingJobIncome += job.amount;
    }

    // 6. Final Prediction
    final totalUpcomingIncome = upcomingJobIncome + upcomingRecurringIncome;

    final predictedMonthEnd = balance +
        totalUpcomingIncome +
        upcomingDebtCollections -
        predictedVariableSpending -
        upcomingDebtPayments -
        upcomingRecurringExpenses;

    _logger.i('''
🧮 PROJECTION MATH DEBUG (ROLLING 30 DAYS):
----------------------------------------
   Current Balance:      ${balance.toStringAsFixed(2)}
+  Upcoming Income:      ${totalUpcomingIncome.toStringAsFixed(2)}
+  Debt Collections:     ${upcomingDebtCollections.toStringAsFixed(2)}
-  Variable Spending:    ${predictedVariableSpending.toStringAsFixed(2)}
-  Debt Payments:        ${upcomingDebtPayments.toStringAsFixed(2)}
-  Recurring Expenses:   ${upcomingRecurringExpenses.toStringAsFixed(2)}
----------------------------------------
=  PREDICTED (+30d):     ${predictedMonthEnd.toStringAsFixed(2)}
''');

    // daysUntilBroke calculation
    int? daysUntilBroke;
    final effectiveBalance = balance +
        totalUpcomingIncome +
        upcomingDebtCollections -
        upcomingDebtPayments -
        upcomingRecurringExpenses;

    if (avgDailyVariableSpending > 0 && effectiveBalance > 0) {
      daysUntilBroke = (effectiveBalance / avgDailyVariableSpending).floor();
    }

    // Safe daily spending
    final buffer = monthlyIncome * 0.10;
    final safeDailySpending = daysRemaining > 0
        ? max(0, (effectiveBalance - buffer) / daysRemaining)
        : 0;

    return CashFlowPrediction(
      currentBalance: balance,
      predictedMonthEndBalance: predictedMonthEnd,
      avgDailySpending: avgDailyVariableSpending.toDouble(),
      safeDailySpending: safeDailySpending.toDouble(),
      daysUntilBroke: daysUntilBroke,
      upcomingDebtPayments: upcomingDebtPayments + upcomingRecurringExpenses,
      daysRemainingInMonth: daysRemaining,
      willSurviveMonth: predictedMonthEnd > 0,
      upcomingIncome: totalUpcomingIncome,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NET WORTH ANALYSIS
  // ═══════════════════════════════════════════════════════════════════════════

  NetWorthAnalysis _calculateNetWorth(
    double currentBalance,
    List<Debt> debts,
    List<FinancialGoal> goals,
  ) {
    // Assets
    final liquidAssets = currentBalance;
    final lentMoney = debts
        .where((d) => !d.isPaidOff && d.type == DebtType.lent)
        .fold(0.0, (sum, d) => sum + d.remainingAmount);
    final goalSavings = goals.fold(0.0, (sum, g) => sum + g.currentAmount);

    final totalAssets = liquidAssets + lentMoney + goalSavings;

    // Liabilities
    final borrowedMoney = debts
        .where((d) => !d.isPaidOff && d.type == DebtType.borrowed)
        .fold(0.0, (sum, d) => sum + d.remainingAmount);

    final totalLiabilities = borrowedMoney;

    final netWorth = totalAssets - totalLiabilities;
    final debtRatio = totalAssets > 0 ? totalLiabilities / totalAssets : 0.0;

    return NetWorthAnalysis(
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWorth: netWorth,
      liquidAssets: liquidAssets,
      debtRatio: debtRatio.toDouble(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MULTI-MONTH PROJECTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate projected income for a specific future month
  /// This accounts for time-limited jobs and recurring income that may end
  double _getProjectedIncomeForMonth(DateTime targetMonth, List<Job> jobs,
      List<RecurringTransaction> recurringIncome) {
    double projectedIncome = 0.0;

    // Income from jobs that are still active in the target month
    for (final job in jobs) {
      // Skip inactive jobs
      if (!job.isActive) continue;

      // Check if job ends before target month
      if (job.endDate != null && job.endDate!.isBefore(targetMonth)) {
        continue; // Job has ended, don't include
      }

      // Add job income (monthly equivalent)
      projectedIncome += job.monthlyIncome;
    }

    // Income from recurring transactions that are still active
    for (final recurring in recurringIncome) {
      // Skip inactive or non-income recurring
      if (!recurring.isActive) continue;
      if (recurring.type != TransactionType.income) continue;

      // Check if recurring ends before target month
      if (recurring.endDate != null &&
          recurring.endDate!.isBefore(targetMonth)) {
        continue; // Recurring has ended
      }

      // Calculate monthly equivalent based on frequency
      double monthlyAmount = recurring.amount;
      if (recurring.frequency == Frequency.weekly) {
        monthlyAmount = recurring.amount * 4.33; // Average weeks per month
      } else if (recurring.frequency == Frequency.daily) {
        monthlyAmount = recurring.amount * 30; // Average days per month
      }

      projectedIncome += monthlyAmount;
    }

    return projectedIncome;
  }

  /// Project financial status for next N months
  MultiMonthProjection projectNextMonths({int monthsAhead = 6}) {
    final now = DateTime.now();
    final transactions = _context.allTransactions.toList();
    final jobs = _context.allJobs.toList();
    final recurringTransactions = _context.allRecurringTransactions.toList();
    final currentMonthlyIncome = _context.totalMonthlyIncome.value;
    final monthlyExpenses = _context.totalMonthlyExpenses.value;
    final balance = _context.currentBalance.value;

    // Calculate average monthly savings rate based on current income
    final avgSavings = currentMonthlyIncome - monthlyExpenses;

    // Get recurring expenses from last 3 months for better accuracy
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final recentExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense && t.date.isAfter(threeMonthsAgo))
        .fold(0.0, (sum, t) => sum + t.amount);
    final avgMonthlyExpenseActual = recentExpenses / 3;

    // Use actual spending if available, otherwise use recorded expenses
    final effectiveMonthlyExpense =
        avgMonthlyExpenseActual > 0 ? avgMonthlyExpenseActual : monthlyExpenses;

    final projections = <MonthProjection>[];
    var runningBalance = balance;
    bool incomeWillChange = false;

    final monthNames = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];

    for (int i = 1; i <= monthsAhead; i++) {
      final futureMonth = DateTime(now.year, now.month + i, 1);

      // Use dynamic income calculation that respects endDate
      final projectedIncome = _getProjectedIncomeForMonth(
        futureMonth,
        jobs,
        recurringTransactions,
      );

      // Track if income changes from current
      if (projectedIncome < currentMonthlyIncome * 0.95) {
        incomeWillChange = true;
      }

      final projectedExpense = effectiveMonthlyExpense;
      final projectedSavings = projectedIncome - projectedExpense;

      runningBalance += projectedSavings;

      projections.add(MonthProjection(
        month: futureMonth,
        monthName: monthNames[futureMonth.month - 1],
        projectedIncome: projectedIncome,
        projectedExpenses: projectedExpense,
        projectedBalance: runningBalance,
        projectedSavings: projectedSavings,
        isRisky: runningBalance < 0 || projectedSavings < 0,
      ));
    }

    // Calculate totals
    final savings3Months =
        projections.take(3).fold(0.0, (sum, p) => sum + p.projectedSavings);
    final savings6Months =
        projections.fold(0.0, (sum, p) => sum + p.projectedSavings);

    // Determine trend
    String trend;
    String outlook;

    if (avgSavings > currentMonthlyIncome * 0.2) {
      trend = 'improving';
      outlook =
          'Excellente trajectoire! Vous épargnez ${(avgSavings / currentMonthlyIncome * 100).toStringAsFixed(0)}% de vos revenus.';
    } else if (avgSavings > 0) {
      trend = 'stable';
      outlook =
          'Situation stable. Vous épargnez ${avgSavings.toStringAsFixed(0)} FCFA par mois.';
    } else {
      trend = 'declining';
      outlook =
          'Attention: Vos dépenses dépassent vos revenus de ${(-avgSavings).toStringAsFixed(0)} FCFA/mois.';
    }

    // Check for future risks
    final riskyMonths = projections.where((p) => p.isRisky).length;
    if (riskyMonths > 0) {
      outlook =
          '⚠️ Risque de découvert dans $riskyMonths mois si tendance continue.';
      trend = 'declining';
    } else if (incomeWillChange) {
      outlook +=
          '\nNote: Une baisse de revenus est prévue dans les prochains mois.';
    }

    return MultiMonthProjection(
      months: projections,
      projectedSavingsIn3Months: savings3Months,
      projectedSavingsIn6Months: savings6Months,
      trend: trend,
      outlook: outlook,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SMART RECOMMENDATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  List<SmartRecommendation> _generateRecommendations(
    List<LocalTransaction> transactions,
    List<Debt> debts,
    List<FinancialGoal> goals,
    List<Budget> budgets,
    double balance,
    double monthlyIncome,
  ) {
    final recommendations = <SmartRecommendation>[];

    final spending = _analyzeSpendingBehavior(transactions, monthlyIncome);
    final debtStrategy = _analyzeDebtStrategy(debts, monthlyIncome, balance);
    final goalProgress = _analyzeGoalProgress(goals, monthlyIncome, balance);
    final budgetHealth = _analyzeBudgetHealth(budgets, transactions);
    final cashFlow =
        _predictCashFlow(transactions, debts, monthlyIncome, balance);

    // Priority 1: Immediate survival
    if (!cashFlow.willSurviveMonth) {
      recommendations.add(SmartRecommendation(
        priority: RecommendationPriority.critical,
        category: RecommendationCategory.spending,
        title: 'Urgence: Risque de découvert',
        description:
            'Vous risquez de manquer d\'argent avant la fin du mois. Réduisez immédiatement vos dépenses.',
        actionLabel: 'Voir mon budget',
        actionRoute: '/budget',
        impact: 'Éviter le découvert',
      ));
    }

    // Priority 2: Reckless spending
    if (spending.pattern == SpendingPattern.reckless) {
      recommendations.add(SmartRecommendation(
        priority: RecommendationPriority.high,
        category: RecommendationCategory.spending,
        title: 'Dépenses excessives détectées',
        description:
            'Vous dépensez ${(spending.velocityRatio * 100).toStringAsFixed(0)}% plus vite que prévu. Limitez votre budget quotidien à ${cashFlow.safeDailySpending.toStringAsFixed(0)} F.',
        actionLabel: 'Ajuster mon budget',
        actionRoute: '/budget',
        impact:
            'Économiser ${((spending.avgDailySpending - cashFlow.safeDailySpending) * spending.daysUntilMonthEnd).toStringAsFixed(0)} F ce mois',
      ));
    }

    // Priority 3: Debt at high burden
    if (debtStrategy.paymentBurden > 0.35) {
      recommendations.add(SmartRecommendation(
        priority: RecommendationPriority.high,
        category: RecommendationCategory.debt,
        title: 'Charge de dette élevée',
        description:
            '${(debtStrategy.paymentBurden * 100).toStringAsFixed(0)}% de votre revenu va aux dettes. Concentrez-vous sur rembourser "${debtStrategy.priorityDebt?.personName ?? 'la plus petite dette'}" en premier.',
        actionLabel: 'Gérer mes dettes',
        actionRoute: '/debt',
        impact:
            'Libérer ${debtStrategy.priorityDebt?.minPayment.toStringAsFixed(0) ?? '0'} F/mois après remboursement',
      ));
    }

    // Priority 4: Budget exceeded
    if (budgetHealth.exceededCount > 0 && budgetHealth.worstBudget != null) {
      recommendations.add(SmartRecommendation(
        priority: RecommendationPriority.medium,
        category: RecommendationCategory.budget,
        title: '${budgetHealth.exceededCount} budget(s) dépassé(s)',
        description:
            'Vous avez dépassé votre budget de ${((budgetHealth.worstBudget!.usagePercent - 1) * 100).toStringAsFixed(0)}%.',
        actionLabel: 'Voir les détails',
        actionRoute: '/budget',
        impact: 'Reprendre le contrôle de vos dépenses',
      ));
    }

    // Priority 5: Goals at risk
    if (goalProgress.goalsAtRisk > 0 && goalProgress.priorityGoal != null) {
      final goal = goalProgress.priorityGoal!;
      recommendations.add(SmartRecommendation(
        priority: RecommendationPriority.medium,
        category: RecommendationCategory.goals,
        title: 'Objectif "${goal.goal.title}" en retard',
        description:
            'Vous êtes ${goal.monthsBehindSchedule ?? 0} mois en retard. Augmentez votre épargne à ${goal.recommendedMonthlyContribution?.toStringAsFixed(0) ?? 'N/A'} F/mois.',
        actionLabel: 'Voir mes objectifs',
        actionRoute: '/goals',
        impact: 'Atteindre votre objectif à temps',
      ));
    }

    // Priority 6: Positive reinforcement
    if (spending.pattern == SpendingPattern.conservative &&
        budgetHealth.healthyCount == budgets.length) {
      recommendations.add(SmartRecommendation(
        priority: RecommendationPriority.low,
        category: RecommendationCategory.savings,
        title: 'Excellente gestion financière!',
        description:
            'Vous gérez bien votre argent. Pensez à investir ${(monthlyIncome * 0.10).toStringAsFixed(0)} F supplémentaires dans vos objectifs.',
        actionLabel: 'Épargner plus',
        actionRoute: '/goals',
        impact: 'Atteindre vos objectifs plus rapidement',
      ));
    }

    // Sort by priority
    recommendations
        .sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return recommendations;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OVERALL RISK CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════

  RiskLevel _calculateOverallRisk(
    List<LocalTransaction> transactions,
    List<Debt> debts,
    List<FinancialGoal> goals,
    double balance,
    double monthlyIncome,
  ) {
    if (monthlyIncome <= 0) return RiskLevel.medium;

    // 1. Calculate Component Scores (0-100, where 100 is perfect)

    // Balance Score (Buffer): Target is 1.0x monthly income
    final balanceRatio = balance / monthlyIncome;
    double balanceScore = (balanceRatio * 100).clamp(0, 100);
    // Be lenient: 0.5x income is already "Good" (100 pts)
    balanceScore = (balanceRatio * 200).clamp(0, 100);

    // Velocity Score (Spending Control): Target is < 0.9x income
    final spending = _analyzeSpendingBehavior(transactions, monthlyIncome);
    double velocityScore = 100;
    if (spending.velocityRatio > 1.2) {
      velocityScore = 0;
    } else if (spending.velocityRatio > 1.0)
      velocityScore = 40;
    else if (spending.velocityRatio > 0.9)
      velocityScore = 70;
    else
      velocityScore = 100;

    // Debt Score (Burden): Target is < 20% DTI
    final debtStrategy = _analyzeDebtStrategy(debts, monthlyIncome, balance);
    double debtScore = 100;
    if (debtStrategy.paymentBurden > 0.50) {
      debtScore = 0;
    } else if (debtStrategy.paymentBurden > 0.35)
      debtScore = 30;
    else if (debtStrategy.paymentBurden > 0.20)
      debtScore = 60;
    else
      debtScore = 100;

    // Impulsive Score (Behavior): Target 0
    double behaviorScore = 100;
    if (spending.impulsiveTransactionCount > 3) {
      behaviorScore = 20;
    } else if (spending.impulsiveTransactionCount > 1)
      behaviorScore = 60;
    else if (spending.impulsiveTransactionCount > 0) behaviorScore = 80;

    // 2. Weighted Average
    // Spending (35%) + Debt (35%) + Balance (15%) + Behavior (15%)
    final totalScore = (velocityScore * 0.35) +
        (debtScore * 0.35) +
        (balanceScore * 0.15) +
        (behaviorScore * 0.15);

    // 3. Map to Risk Level (Inverted: High Score = Low Risk)
    if (totalScore >= 80) return RiskLevel.minimal; // Excellent health
    if (totalScore >= 60) return RiskLevel.low; // Good
    if (totalScore >= 40) return RiskLevel.medium; // Warning
    if (totalScore >= 20) return RiskLevel.high; // Danger
    return RiskLevel.critical; // Emergency
  }
}
