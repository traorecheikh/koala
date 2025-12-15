import 'package:get/get.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
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

    // React to any financial change
    ever(_context.allTransactions, (_) => _recalculate());
    ever(_context.allDebts, (_) => _recalculate());
    ever(_context.allGoals, (_) => _recalculate());
    ever(_context.allBudgets, (_) => _recalculate());
    ever(_context.currentBalance, (_) => _recalculate());

    _recalculate();
  }

  void _recalculate() {
    _logger.d('SmartFinancialBrain: Recalculating intelligence...');

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

    // This month's expenses
    final thisMonthExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense && t.date.isAfter(monthStart))
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
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - dayOfMonth;

    // Calculate average daily spending
    final monthStart = DateTime(now.year, now.month, 1);
    final thisMonthExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense && t.date.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.amount);
    final avgDailySpending =
        dayOfMonth > 0 ? thisMonthExpenses / dayOfMonth : 0;

    // Predict upcoming spending
    final predictedSpendingRemaining = avgDailySpending * daysRemaining;

    // Upcoming debt payments
    final upcomingDebtPayments = debts
        .where((d) => !d.isPaidOff && d.createdAt.day > dayOfMonth)
        .fold(0.0, (sum, d) => sum + d.minPayment);

    // FIX: Calculate UPCOMING INCOME from jobs before month end
    double upcomingIncome = 0;
    for (final job in _context.allJobs) {
      if (!job.isActive) continue;
      final payDay = job.paymentDate.day;
      // If payday is after today but within this month, add it
      if (payDay > dayOfMonth && payDay <= daysInMonth) {
        upcomingIncome += job.amount;
      }
    }

    // Month-end prediction NOW includes upcoming salary
    final predictedMonthEnd = balance +
        upcomingIncome -
        predictedSpendingRemaining -
        upcomingDebtPayments;

    // Days until broke (if spending continues at current rate)
    int? daysUntilBroke;
    if (avgDailySpending > 0 && balance > 0) {
      // Factor in upcoming income for more accurate "broke" calculation
      final effectiveBalance = balance + upcomingIncome;
      daysUntilBroke = (effectiveBalance / avgDailySpending).floor();
    }

    // Calculate safe daily spending allowance
    final safeBuffer = monthlyIncome * 0.10; // Keep 10% buffer
    final effectiveBalanceForSafe = balance + upcomingIncome;
    final safeDailySpending = daysRemaining > 0
        ? max(
            0,
            (effectiveBalanceForSafe - upcomingDebtPayments - safeBuffer) /
                daysRemaining)
        : 0;

    return CashFlowPrediction(
      currentBalance: balance,
      predictedMonthEndBalance: predictedMonthEnd,
      avgDailySpending: avgDailySpending.toDouble(),
      safeDailySpending: safeDailySpending.toDouble(),
      daysUntilBroke: daysUntilBroke,
      upcomingDebtPayments: upcomingDebtPayments,
      daysRemainingInMonth: daysRemaining,
      willSurviveMonth: predictedMonthEnd > 0,
      upcomingIncome: upcomingIncome, // Added field
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
    if (spending.velocityRatio > 1.2)
      velocityScore = 0;
    else if (spending.velocityRatio > 1.0)
      velocityScore = 40;
    else if (spending.velocityRatio > 0.9)
      velocityScore = 70;
    else
      velocityScore = 100;

    // Debt Score (Burden): Target is < 20% DTI
    final debtStrategy = _analyzeDebtStrategy(debts, monthlyIncome, balance);
    double debtScore = 100;
    if (debtStrategy.paymentBurden > 0.50)
      debtScore = 0;
    else if (debtStrategy.paymentBurden > 0.35)
      debtScore = 30;
    else if (debtStrategy.paymentBurden > 0.20)
      debtScore = 60;
    else
      debtScore = 100;

    // Impulsive Score (Behavior): Target 0
    double behaviorScore = 100;
    if (spending.impulsiveTransactionCount > 3)
      behaviorScore = 20;
    else if (spending.impulsiveTransactionCount > 1)
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

// ═══════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════

class FinancialIntelligence {
  final SpendingBehavior spendingBehavior;
  final DebtStrategy debtStrategy;
  final GoalProgressAnalysis goalProgress;
  final BudgetHealth budgetHealth;
  final CashFlowPrediction cashFlowPrediction;
  final List<SmartRecommendation> recommendations;
  final RiskLevel overallRiskLevel;

  FinancialIntelligence({
    required this.spendingBehavior,
    required this.debtStrategy,
    required this.goalProgress,
    required this.budgetHealth,
    required this.cashFlowPrediction,
    required this.recommendations,
    required this.overallRiskLevel,
  });

  factory FinancialIntelligence.empty() => FinancialIntelligence(
        spendingBehavior: SpendingBehavior.empty(),
        debtStrategy: DebtStrategy.empty(),
        goalProgress: GoalProgressAnalysis.empty(),
        budgetHealth: BudgetHealth.empty(),
        cashFlowPrediction: CashFlowPrediction.empty(),
        recommendations: [],
        overallRiskLevel: RiskLevel.unknown,
      );
}

enum SpendingPattern { reckless, aggressive, atRisk, balanced, conservative }

enum PayoffStrategy { seekHelp, aggressive, balanced, comfortable }

enum BudgetStatus { exceeded, atRisk, onTrack, underBudget }

enum RiskLevel { critical, high, medium, low, minimal, unknown }

enum RecommendationPriority { critical, high, medium, low }

enum RecommendationCategory { spending, debt, budget, goals, savings }

class SpendingBehavior {
  final double totalSpentThisMonth;
  final double velocityRatio;
  final SpendingPattern pattern;
  final double avgDailySpending;
  final int impulsiveTransactionCount;
  final LocalTransaction? largestTransaction;
  final List<int> spikeDays;
  final String? topSpendingCategory;
  final Map<String, double> categoryBreakdown;
  final int daysUntilMonthEnd;
  final double projectedMonthEndSpending;

  SpendingBehavior({
    required this.totalSpentThisMonth,
    required this.velocityRatio,
    required this.pattern,
    required this.avgDailySpending,
    required this.impulsiveTransactionCount,
    this.largestTransaction,
    required this.spikeDays,
    this.topSpendingCategory,
    required this.categoryBreakdown,
    required this.daysUntilMonthEnd,
    required this.projectedMonthEndSpending,
  });

  factory SpendingBehavior.empty() => SpendingBehavior(
        totalSpentThisMonth: 0,
        velocityRatio: 0,
        pattern: SpendingPattern.balanced,
        avgDailySpending: 0,
        impulsiveTransactionCount: 0,
        spikeDays: [],
        categoryBreakdown: {},
        daysUntilMonthEnd: 30,
        projectedMonthEndSpending: 0,
      );
}

class DebtStrategy {
  final double totalDebt;
  final double totalMonthlyPayments;
  final double debtToIncomeRatio;
  final double paymentBurden;
  final int activeDebtCount;
  final List<Debt> debtsAtRisk;
  final List<Debt> optimalPayoffOrder;
  final PayoffStrategy recommendedStrategy;
  final int estimatedMonthsToDebtFree;
  final Debt? priorityDebt;

  DebtStrategy({
    required this.totalDebt,
    required this.totalMonthlyPayments,
    required this.debtToIncomeRatio,
    required this.paymentBurden,
    required this.activeDebtCount,
    required this.debtsAtRisk,
    required this.optimalPayoffOrder,
    required this.recommendedStrategy,
    required this.estimatedMonthsToDebtFree,
    this.priorityDebt,
  });

  factory DebtStrategy.empty() => DebtStrategy(
        totalDebt: 0,
        totalMonthlyPayments: 0,
        debtToIncomeRatio: 0,
        paymentBurden: 0,
        activeDebtCount: 0,
        debtsAtRisk: [],
        optimalPayoffOrder: [],
        recommendedStrategy: PayoffStrategy.comfortable,
        estimatedMonthsToDebtFree: 0,
      );
}

class GoalProgressAnalysis {
  final double totalTargetAmount;
  final double totalSavedAmount;
  final double overallProgress;
  final int activeGoalCount;
  final int goalsOnTrack;
  final int goalsAtRisk;
  final List<GoalInsight> goalInsights;
  final double monthlySavingsCapacity;
  final GoalInsight? priorityGoal;

  GoalProgressAnalysis({
    required this.totalTargetAmount,
    required this.totalSavedAmount,
    required this.overallProgress,
    required this.activeGoalCount,
    required this.goalsOnTrack,
    required this.goalsAtRisk,
    required this.goalInsights,
    required this.monthlySavingsCapacity,
    this.priorityGoal,
  });

  factory GoalProgressAnalysis.empty() => GoalProgressAnalysis(
        totalTargetAmount: 0,
        totalSavedAmount: 0,
        overallProgress: 0,
        activeGoalCount: 0,
        goalsOnTrack: 0,
        goalsAtRisk: 0,
        goalInsights: [],
        monthlySavingsCapacity: 0,
      );
}

class GoalInsight {
  final FinancialGoal goal;
  final double progressPercent;
  final double remainingAmount;
  final int? estimatedMonthsToComplete;
  final bool isOnTrack;
  final int? monthsBehindSchedule;
  final double? recommendedMonthlyContribution;

  GoalInsight({
    required this.goal,
    required this.progressPercent,
    required this.remainingAmount,
    this.estimatedMonthsToComplete,
    required this.isOnTrack,
    this.monthsBehindSchedule,
    this.recommendedMonthlyContribution,
  });
}

class BudgetHealth {
  final int totalBudgets;
  final int exceededCount;
  final int atRiskCount;
  final int healthyCount;
  final List<BudgetInsight> budgetInsights;
  final BudgetInsight? worstBudget;
  final int overallHealth; // 0-100

  BudgetHealth({
    required this.totalBudgets,
    required this.exceededCount,
    required this.atRiskCount,
    required this.healthyCount,
    required this.budgetInsights,
    this.worstBudget,
    required this.overallHealth,
  });

  factory BudgetHealth.empty() => BudgetHealth(
        totalBudgets: 0,
        exceededCount: 0,
        atRiskCount: 0,
        healthyCount: 0,
        budgetInsights: [],
        overallHealth: 100,
      );
}

class BudgetInsight {
  final Budget budget;
  final double spent;
  final double usagePercent;
  final BudgetStatus status;
  final double remainingAmount;
  final double dailyAllowance;
  final double projectedMonthEnd;

  BudgetInsight({
    required this.budget,
    required this.spent,
    required this.usagePercent,
    required this.status,
    required this.remainingAmount,
    required this.dailyAllowance,
    required this.projectedMonthEnd,
  });
}

class CashFlowPrediction {
  final double currentBalance;
  final double predictedMonthEndBalance;
  final double avgDailySpending;
  final double safeDailySpending;
  final int? daysUntilBroke;
  final double upcomingDebtPayments;
  final double upcomingIncome; // New: upcoming salary/income
  final int daysRemainingInMonth;
  final bool willSurviveMonth;

  CashFlowPrediction({
    required this.currentBalance,
    required this.predictedMonthEndBalance,
    required this.avgDailySpending,
    required this.safeDailySpending,
    this.daysUntilBroke,
    required this.upcomingDebtPayments,
    this.upcomingIncome = 0,
    required this.daysRemainingInMonth,
    required this.willSurviveMonth,
  });

  factory CashFlowPrediction.empty() => CashFlowPrediction(
        currentBalance: 0,
        predictedMonthEndBalance: 0,
        avgDailySpending: 0,
        safeDailySpending: 0,
        upcomingDebtPayments: 0,
        upcomingIncome: 0,
        daysRemainingInMonth: 30,
        willSurviveMonth: true,
      );
}

class SmartRecommendation {
  final RecommendationPriority priority;
  final RecommendationCategory category;
  final String title;
  final String description;
  final String actionLabel;
  final String actionRoute;
  final String impact;

  SmartRecommendation({
    required this.priority,
    required this.category,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.actionRoute,
    required this.impact,
  });
}
