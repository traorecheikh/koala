import 'package:get/get.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/data/models/ml/financial_intelligence.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/time_series_engine.dart';
import 'package:koaa/app/services/ml/contextual_brain.dart'; // Fixed: Added import
import 'package:koaa/app/services/predictive_spending_service.dart';
import 'package:logger/logger.dart';
import 'dart:math';

/// DTO for passing data to the background isolate
class AnalysisInput {
  final List<LocalTransaction> transactions;
  final List<Debt> debts;
  final List<FinancialGoal> goals;
  final List<Budget> budgets;
  final List<Job> jobs;
  final List<RecurringTransaction> recurringTransactions;
  final double currentBalance;
  final double incomeReceivedSoFar; // Added field
  final double
      monthlyIncome; // Renamed conceptually to totalProjectedIncome in usage
  final double monthlyExpenses;
  final ForecastResult? forecast;

  AnalysisInput({
    required this.transactions,
    required this.debts,
    required this.goals,
    required this.budgets,
    required this.jobs,
    required this.recurringTransactions,
    required this.currentBalance,
    required this.incomeReceivedSoFar, // Added
    required this.monthlyIncome,
    required this.monthlyExpenses,
    this.forecast,
  });
}

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
    // Yield to UI thread before starting setup
    await Future.delayed(Duration.zero);

    // Check if ML Engine is available and get forecast
    ForecastResult? forecast;
    try {
      if (Get.isRegistered<KoalaMLEngine>()) {
        final mlEngine = Get.find<KoalaMLEngine>();

        // TRIGGER RETRAINING if data changed (debounced)
        // We do this non-blocking or awaited?
        // Awaiting ensures forecast is fresh for the analysis below.
        if (_context.allTransactions.isNotEmpty) {
          await mlEngine.refreshModels(_context.allTransactions.toList());
        }

        forecast = mlEngine.currentForecast;
      }

      // Check for ContextualBrain separately as it drives the UI auto-complete
      if (Get.isRegistered<ContextualBrain>()) {
        // Fire and forget to not block main analysis
        Get.find<ContextualBrain>().refresh();
      }
    } catch (_) {}

    // Prepare data for the isolate
    // We create a snapshot of the current state
    final effectiveMonthlyIncome = max(
      _context.totalMonthlyIncome.value,
      _calculateProjectedIncomeForMonth(
        DateTime.now(),
        _context.allJobs.toList(),
        _context.allRecurringTransactions.toList(),
      ),
    );

    final input = AnalysisInput(
      transactions: _context.allTransactions.toList(),
      debts: _context.allDebts.toList(),
      goals: _context.allGoals.toList(),
      budgets: _context.allBudgets.toList(),
      jobs: _context.allJobs.toList(),
      recurringTransactions: _context.allRecurringTransactions.toList(),
      currentBalance: _context.currentBalance.value,
      incomeReceivedSoFar: _context.totalMonthlyIncome.value,
      monthlyIncome: effectiveMonthlyIncome,
      monthlyExpenses: _context.totalMonthlyExpenses.value,
      forecast: forecast,
    );

    if (input.transactions.isEmpty && input.jobs.isEmpty) {
      _logger.w('SmartFinancialBrain: No transactions or jobs to analyze.');
      // We still run analysis to get "0" states instead of returning nothing?
      // If we return, intelligence remains empty.
      // Let's proceed even if empty to update UI to "Safe/Neutral" instead of stale.
    }

    try {
      _logger.i('SmartFinancialBrain: Starting analysis... '
          'Income: ${input.monthlyIncome}, Jobs: ${input.jobs.length}, TXs: ${input.transactions.length}');

      // Running on main thread to avoid Isolate serialization issues with Hive objects
      final result = _runPrimaryAnalysis(input);
      intelligence.value = result;

      _logger.i(
          'SmartFinancialBrain: Intelligence updated successfully. Score: ${result.overallRiskLevel.name}');
    } catch (e, st) {
      _logger.e('SmartFinancialBrain: Analysis failed',
          error: e, stackTrace: st);
    }
  }

  /// Static entry point for the background isolate
  static FinancialIntelligence _runPrimaryAnalysis(AnalysisInput input) {
    return FinancialIntelligence(
      // Core metrics
      spendingBehavior:
          _analyzeSpendingBehavior(input.transactions, input.monthlyIncome),
      debtStrategy: _analyzeDebtStrategy(
          input.debts, input.monthlyIncome, input.currentBalance),
      goalProgress: _analyzeGoalProgress(
          input.goals, input.monthlyIncome, input.currentBalance),
      budgetHealth: _analyzeBudgetHealth(input.budgets, input.transactions),
      cashFlowPrediction: _predictCashFlow(
        input.transactions,
        input.debts,
        // vital FIX: For a 30-day rolling forecast, we expect to receive ~1 month of income.
        // Previously we subtracted incomeReceivedSoFar, which meant if you were paid on the 1st,
        // the 30-day projection assumed ZERO income, leading to "Point Bas" crashes.
        input.monthlyIncome,
        input.currentBalance,
        input.forecast,
      ),
      netWorthAnalysis:
          _calculateNetWorth(input.currentBalance, input.debts, input.goals),

      // Smart recommendations
      recommendations: _generateRecommendations(
          input.transactions,
          input.debts,
          input.goals,
          input.budgets,
          input.currentBalance,
          input.monthlyIncome,
          input.forecast),

      // Risk assessment
      overallRiskLevel: _assessOverallRisk(
        input.transactions,
        input.debts, // Fixed: passed correct arguments to _assessOverallRisk
        input.goals,
        input.currentBalance,
        input.monthlyIncome,
      ),
      spendingAlerts: PredictiveSpendingService().analyzeSpending(
        transactions: input.transactions,
        budgets: input.budgets,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RISK ASSESSMENT (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static RiskLevel _assessOverallRisk(
    List<LocalTransaction> transactions,
    List<Debt> debts,
    List<FinancialGoal> goals,
    double currentBalance,
    double monthlyIncome,
  ) {
    if (monthlyIncome <= 0) return RiskLevel.unknown;

    int riskScore = 0; // Lower is better

    // 1. Spending too fast?
    final spendingBehavior =
        _analyzeSpendingBehavior(transactions, monthlyIncome);
    if (spendingBehavior.pattern == SpendingPattern.reckless) riskScore += 3;
    if (spendingBehavior.pattern == SpendingPattern.aggressive) riskScore += 2;
    if (spendingBehavior.pattern == SpendingPattern.atRisk) riskScore += 1;

    // 2. High debt?
    final debtStrategy =
        _analyzeDebtStrategy(debts, monthlyIncome, currentBalance);
    if (debtStrategy.recommendedStrategy == PayoffStrategy.seekHelp) {
      riskScore += 3;
    }
    if (debtStrategy.recommendedStrategy == PayoffStrategy.aggressive) {
      riskScore += 2;
    }

    // 3. Low savings/buffer?
    if (currentBalance < monthlyIncome * 0.1) {
      riskScore += 2; // Less than 10% buffer
    }
    if (currentBalance < 0) riskScore += 3; // In overdraft

    // 4. Failing goals?
    final goalProgress =
        _analyzeGoalProgress(goals, monthlyIncome, currentBalance);
    if (goalProgress.goalsAtRisk > goalProgress.goalsOnTrack) riskScore += 1;

    // Determine level
    if (riskScore >= 6) return RiskLevel.critical;
    if (riskScore >= 4) return RiskLevel.high;
    if (riskScore >= 2) return RiskLevel.medium;
    if (riskScore >= 1) return RiskLevel.low;

    return RiskLevel.minimal;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SPENDING BEHAVIOR ANALYSIS (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static SpendingBehavior _analyzeSpendingBehavior(
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
    // Category breakdown
    final Map<String, double> categorySpending = {};
    for (final t in thisMonthExpenses) {
      // Default to Enum name if ID is null or empty
      String category = (t.categoryId != null && t.categoryId!.isNotEmpty)
          ? t.categoryId!
          : t.category.name;

      // If ID says "other" (or variants) but Enum knows better, use the Enum name
      final lowerCat = category.toLowerCase().trim();
      if ((lowerCat == 'other' ||
              lowerCat == 'autre' ||
              lowerCat == 'autredépense' ||
              lowerCat == 'autredepense') &&
          t.category != TransactionCategory.otherExpense &&
          t.category != TransactionCategory.otherIncome) {
        category = t.category.name;
      }

      // FINAL FALLBACK: If it's STILL "Other", check the description (User Request)
      // e.g. If description is "Transport", count it as Transport
      if (category.toLowerCase() == 'other' ||
          category.toLowerCase() == 'autre') {
        final descLower = t.description.toLowerCase().trim();
        // Check against standard categories
        for (final catEnum in TransactionCategory.values) {
          if (catEnum.name.toLowerCase() == descLower ||
              catEnum.displayName.toLowerCase() == descLower) {
            category = catEnum.name;
            break;
          }
        }
      }

      // DEBUG: Log weird categories if found
      if (category == 'other' || category == 'Autre') {
        // print('DATA_DEBUG: Found Generic Category for TX ${t.id} (${t.description}): Enum=${t.category}, ID=${t.categoryId}');
        // Commented out to avoid log spam, but available if needed
      }

      categorySpending[category] = (categorySpending[category] ?? 0) + t.amount;
    }

    // DEBUG: Print breakdown keys to verify groupings
    // print('BRAIN_DEBUG: Category Breakdown Keys: ${categorySpending.keys.toList()}');

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
  // DEBT STRATEGY ANALYSIS (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static DebtStrategy _analyzeDebtStrategy(
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
  // GOAL PROGRESS ANALYSIS (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static GoalProgressAnalysis _analyzeGoalProgress(
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
  // BUDGET HEALTH ANALYSIS (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static BudgetHealth _analyzeBudgetHealth(
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
              t.date.isAfter(monthStart) &&
              !t.isCatchUp && // Skip catch-up transactions
              (t.linkedDebtId == null ||
                  t.linkedDebtId!.isEmpty)) // Skip debt/lending
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
  // CASH FLOW PREDICTION (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static CashFlowPrediction _predictCashFlow(
    List<LocalTransaction> transactions,
    List<Debt> debts,
    double upcomingIncome, // Renamed from monthlyIncome
    double balance,
    ForecastResult? forecast, // Passed as argument
  ) {
    // ═══════════════════════════════════════════════════════════════════════════
    // HYBRID FORECAST APPROACH
    // ═══════════════════════════════════════════════════════════════════════════
    // 1. Always calculate manual forecast first (it's our baseline)
    // 2. Check if ML can be trusted (sufficient data + reasonable prediction)
    // 3. If ML is valid and close to manual, use ML (it captures trends better)
    // 4. Otherwise, use manual (more predictable)
    // ═══════════════════════════════════════════════════════════════════════════

    final now = DateTime.now();
    final dayOfMonth = now.day;
    final int daysRemaining = 30; // Rolling 30-day window
    final monthStart = DateTime(now.year, now.month, 1);

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 1: Calculate Manual Forecast (always)
    // ─────────────────────────────────────────────────────────────────────────
    final variableExpenses = transactions.where((t) =>
        t.type == TransactionType.expense &&
        !t.isRecurring && // Skip recurring (rent, subs)
        t.linkedDebtId == null && // Skip debt payments
        !t.date.isBefore(monthStart));

    final totalVariableSpent =
        variableExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final avgDailyVariableSpending =
        dayOfMonth > 0 ? totalVariableSpent / dayOfMonth : 0;
    final predictedVariableSpending = avgDailyVariableSpending * daysRemaining;

    double upcomingDebtPayments = 0.0;
    for (var debt in debts) {
      if (!debt.isPaidOff && debt.type == DebtType.borrowed) {
        upcomingDebtPayments += debt.minPayment;
      }
    }

    final manualPrediction = balance -
        predictedVariableSpending -
        upcomingDebtPayments +
        upcomingIncome;

    print(
        '🔮 [CASHFLOW] MANUAL: $balance - $predictedVariableSpending - $upcomingDebtPayments + $upcomingIncome = $manualPrediction');

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 2: Check if ML can be trusted
    // ─────────────────────────────────────────────────────────────────────────
    bool useML = false;
    double? mlPrediction;

    if (forecast != null && forecast.forecasts.isNotEmpty) {
      // Fix: TimeSeries predicts balance trends based on expenses.
      // We must add the projected income to get the true end-of-month balance.
      mlPrediction = forecast.forecasts.last.predictedBalance + upcomingIncome;

      // Criteria for trusting ML:
      // 1. Sufficient data: at least 60 transactions
      // 2. Sufficient history: at least 60 days of data
      // 3. Reasonable prediction: within 30% of manual calculation

      final hasEnoughTransactions = transactions.length >= 60;

      DateTime? oldestDate;
      if (transactions.isNotEmpty) {
        oldestDate = transactions
            .map((t) => t.date)
            .reduce((a, b) => a.isBefore(b) ? a : b);
      }
      final hasEnoughHistory =
          oldestDate != null && now.difference(oldestDate).inDays >= 60;

      // Check if ML prediction is "reasonable" (within 30% of manual)
      final isReasonable = manualPrediction > 0
          ? (mlPrediction - manualPrediction).abs() / manualPrediction < 0.30
          : mlPrediction.abs() < 100000; // Fallback check for edge cases

      useML = hasEnoughTransactions && hasEnoughHistory && isReasonable;

      print(
          '🔮 [CASHFLOW] ML CHECK: txs=${transactions.length}(need 60), history=${oldestDate != null ? now.difference(oldestDate).inDays : 0}d(need 60), '
          'mlPred=$mlPrediction, manualPred=$manualPrediction, diff=${manualPrediction > 0 ? ((mlPrediction - manualPrediction).abs() / manualPrediction * 100).toStringAsFixed(1) : "N/A"}%(max 30%), USE_ML=$useML');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // STEP 3: Return the appropriate prediction
    // ─────────────────────────────────────────────────────────────────────────
    if (useML && mlPrediction != null) {
      // Use ML forecast (captures trends and seasonality)
      final avgDaily = predictedVariableSpending / daysRemaining;

      print('🔮 [CASHFLOW] ✅ USING ML FORECAST: $mlPrediction');

      return CashFlowPrediction(
        currentBalance: balance,
        predictedMonthEndBalance: mlPrediction,
        avgDailySpending: avgDaily,
        safeDailySpending: max(0, mlPrediction / 30),
        daysUntilBroke: forecast?.daysUntilZero,
        upcomingDebtPayments: upcomingDebtPayments,
        daysRemainingInMonth: daysRemaining,
        willSurviveMonth: mlPrediction > 0,
        upcomingIncome: upcomingIncome,
      );
    } else {
      // Use manual calculation (more predictable)
      print('🔮 [CASHFLOW] ✅ USING MANUAL CALC: $manualPrediction');

      return CashFlowPrediction(
        currentBalance: balance,
        predictedMonthEndBalance: manualPrediction,
        avgDailySpending: avgDailyVariableSpending.toDouble(),
        safeDailySpending: max(0, manualPrediction / 30),
        daysUntilBroke: null,
        upcomingDebtPayments: upcomingDebtPayments,
        daysRemainingInMonth: daysRemaining,
        willSurviveMonth: manualPrediction > 0,
        upcomingIncome: upcomingIncome,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NET WORTH ANALYSIS (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static NetWorthAnalysis _calculateNetWorth(
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
  // MULTI-MONTH PROJECTIONS (REMAIN INSTANCE METHODS, CALLING HELPERS)
  // ═══════════════════════════════════════════════════════════════════════════
  // Note: projectNextMonths is likely called from UI explicitly, so it can remain on main thread
  // or be moved later. For now, we leave it as instance member logic if it wasn't called in _recalculate.
  // BUT `_recalculate` logic above doesn't call `projectNextMonths`.
  // However, I must keep the method available for the controller.

  /// Calculate projected income for a specific future month
  /// This accounts for time-limited jobs and recurring income that may end
  static double _calculateProjectedIncomeForMonth(DateTime targetMonth,
      List<Job> jobs, List<RecurringTransaction> recurringIncome) {
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

      // Check if this recurring transaction duplicates a Job (same amount AND frequency)
      // This prevents double counting if the user manually added a recurring transaction for their salary
      final isDuplicateJob = jobs.any((job) {
        if (!job.isActive) return false;

        // Check amount match (exact or very close)
        if ((job.amount - recurring.amount).abs() > 0.01) return false;

        // Check frequency match
        if (job.frequency.name.toLowerCase() == 'monthly' &&
            recurring.frequency.name.toLowerCase() == 'monthly') return true;
        if (job.frequency.name.toLowerCase() == 'weekly' &&
            recurring.frequency.name.toLowerCase() == 'weekly') return true;
        if (job.frequency.name.toLowerCase().contains('bi') &&
            recurring.frequency.name.toLowerCase().contains('bi')) return true;

        return false;
      });

      if (isDuplicateJob) continue;

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
      final projectedIncome = _calculateProjectedIncomeForMonth(
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
  // SMART RECOMMENDATIONS (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static List<SmartRecommendation> _generateRecommendations(
    List<LocalTransaction> transactions,
    List<Debt> debts,
    List<FinancialGoal> goals,
    List<Budget> budgets,
    double balance,
    double monthlyIncome,
    ForecastResult? forecast, // Passed as argument
  ) {
    final recommendations = <SmartRecommendation>[];

    final spending = _analyzeSpendingBehavior(transactions, monthlyIncome);
    final debtStrategy = _analyzeDebtStrategy(debts, monthlyIncome, balance);
    final goalProgress = _analyzeGoalProgress(goals, monthlyIncome, balance);
    final budgetHealth = _analyzeBudgetHealth(budgets, transactions);
    final cashFlow =
        _predictCashFlow(transactions, debts, monthlyIncome, balance, forecast);

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
  // OVERALL RISK CALCULATION (STATIC)
  // ═══════════════════════════════════════════════════════════════════════════

  static RiskLevel _calculateOverallRisk(
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
    } else if (spending.velocityRatio > 1.0) {
      velocityScore = 40;
    } else if (spending.velocityRatio > 0.9) {
      velocityScore = 70;
    } else {
      velocityScore = 100;
    }

    // Debt Score (Burden): Target is < 20% DTI
    final debtStrategy = _analyzeDebtStrategy(debts, monthlyIncome, balance);
    double debtScore = 100;
    if (debtStrategy.paymentBurden > 0.50) {
      debtScore = 0;
    } else if (debtStrategy.paymentBurden > 0.35) {
      debtScore = 30;
    } else if (debtStrategy.paymentBurden > 0.20) {
      debtScore = 60;
    } else {
      debtScore = 100;
    }

    // Impulsive Score (Behavior): Target 0
    double behaviorScore = 100;
    if (spending.impulsiveTransactionCount > 3) {
      behaviorScore = 20;
    } else if (spending.impulsiveTransactionCount > 1) {
      behaviorScore = 60;
    } else if (spending.impulsiveTransactionCount > 0) {
      behaviorScore = 80;
    }

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
