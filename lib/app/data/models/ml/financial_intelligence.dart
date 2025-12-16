import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';

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

/// Multi-month financial projection for smarter long-term planning
class MultiMonthProjection {
  final List<MonthProjection> months;
  final double projectedSavingsIn3Months;
  final double projectedSavingsIn6Months;
  final String trend; // 'improving', 'stable', 'declining'
  final String outlook; // Summary message

  MultiMonthProjection({
    required this.months,
    required this.projectedSavingsIn3Months,
    required this.projectedSavingsIn6Months,
    required this.trend,
    required this.outlook,
  });

  factory MultiMonthProjection.empty() => MultiMonthProjection(
        months: [],
        projectedSavingsIn3Months: 0,
        projectedSavingsIn6Months: 0,
        trend: 'stable',
        outlook: 'Pas assez de données',
      );
}

/// Single month projection data
class MonthProjection {
  final DateTime month;
  final String monthName;
  final double projectedIncome;
  final double projectedExpenses;
  final double projectedBalance;
  final double projectedSavings;
  final bool isRisky; // Balance goes negative

  MonthProjection({
    required this.month,
    required this.monthName,
    required this.projectedIncome,
    required this.projectedExpenses,
    required this.projectedBalance,
    required this.projectedSavings,
    required this.isRisky,
  });
}
