import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart'; // Added import
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:logger/logger.dart';

class FinancialHealthScorer {
  final _logger = Logger();

  FinancialHealthScore calculateScore({
    required FinancialContextService context,
    required UserFinancialProfile profile,
  }) {
    _logger.d('--- Calculating Financial Health ---');
    double totalScore = 0;
    final factors = <HealthFactor>[];

    // 1. Budget Adherence (20%)
    double budgetScore = _calculateBudgetScore(context);
    _logger.d('Budget Score: $budgetScore');
    factors.add(HealthFactor(
      name: 'Budgets',
      score: budgetScore,
      weight: 0.2,
      description: 'Respect des limites fixées',
    ));
    totalScore += budgetScore * 0.2;

    // 2. Goal Progress (20%)
    double goalScore = _calculateGoalScore(context);
    _logger.d('Goal Score: $goalScore');
    factors.add(HealthFactor(
      name: 'Objectifs',
      score: goalScore,
      weight: 0.2,
      description: 'Avancement des projets',
    ));
    totalScore += goalScore * 0.2;

    // 3. Debt-to-Income Ratio (20%)
    double debtScore = _calculateDebtScore(context);
    _logger.d('Debt Score: $debtScore (Income: ${context.totalMonthlyIncome.value}, Debt Payments: ${context.totalMonthlyDebtPayments.value})');
    factors.add(HealthFactor(
      name: 'Dettes',
      score: debtScore,
      weight: 0.2,
      description: 'Ratio dette/revenu',
    ));
    totalScore += debtScore * 0.2;

    // 4. Savings Rate (20%)
    double savingsScore = _calculateSavingsScore(context);
    _logger.d('Savings Score: $savingsScore (Avg Savings: ${context.averageMonthlySavings.value})');
    factors.add(HealthFactor(
      name: 'Épargne',
      score: savingsScore,
      weight: 0.2,
      description: 'Capacité d\'épargne',
    ));
    totalScore += savingsScore * 0.2;

    // 5. Cash Flow Stability (10%)
    double consistencyScore = (profile.consistencyScore * 100).clamp(0, 100);
    _logger.d('Consistency Score: $consistencyScore');
    factors.add(HealthFactor(
      name: 'Stabilité',
      score: consistencyScore,
      weight: 0.1,
      description: 'Régularité des dépenses',
    ));
    totalScore += consistencyScore * 0.1;

    // 6. Emergency Fund Coverage (10%)
    double emergencyScore = _calculateEmergencyScore(context);
    _logger.d('Emergency Score: $emergencyScore (Liquidity: ${context.currentBalance.value})');
    factors.add(HealthFactor(
      name: 'Sécurité',
      score: emergencyScore,
      weight: 0.1,
      description: 'Couverture des imprévus',
    ));
    totalScore += emergencyScore * 0.1;

    _logger.i('FINAL HEALTH SCORE: ${totalScore.round()}');

    return FinancialHealthScore(
      totalScore: totalScore.round(),
      factors: factors,
      calculatedAt: DateTime.now(),
    );
  }

  double _calculateBudgetScore(FinancialContextService context) {
    if (context.allBudgets.isEmpty) return 50.0; // Neutral if no budgets

    int budgetsMet = 0;
    int totalBudgets = 0;
    final now = DateTime.now();

    // Consider budgets relevant to current month
    final currentBudgets = context.allBudgets.where((b) => b.year == now.year && b.month == now.month).toList();
    if (currentBudgets.isEmpty) return 50.0;

    for (var budget in currentBudgets) {
      final spent = context.getSpentAmountForCategory(budget.categoryId, now.year, now.month);
      if (spent <= budget.amount) {
        budgetsMet++;
      }
      totalBudgets++;
    }

    return (budgetsMet / totalBudgets) * 100;
  }

  double _calculateGoalScore(FinancialContextService context) {
    final activeGoals = context.allGoals.where((g) => g.status == GoalStatus.active).toList();
    if (activeGoals.isEmpty) return 50.0; // Neutral

    double totalProgress = 0;
    for (var goal in activeGoals) {
      totalProgress += goal.progressPercentage;
    }

    // Average progress. Cap at 100?
    // Maybe better: are they "on track"?
    // For simplicity, use average progress but weighted by expected timeline?
    // Let's stick to simple average progress for now, maybe capped.
    // Actually, "Score" shouldn't be just progress %, but "Health" of goals.
    // If progress > 0 it's good.
    // Let's say if average progress is > 10% per month it's great?
    // Fallback: Average progress % directly is a bit raw.
    // Let's use: Goal Health = (Goals with recent contribution / Total Goals) * 100?
    // Or just normalized progress.
    return (totalProgress / activeGoals.length).clamp(0, 100);
  }

  double _calculateDebtScore(FinancialContextService context) {
    double monthlyIncome = context.totalMonthlyIncome.value;
    double monthlyDebt = context.totalMonthlyDebtPayments.value;

    if (monthlyIncome == 0) return monthlyDebt > 0 ? 0 : 50; // No income, debt is bad, no debt is neutral

    double dti = monthlyDebt / monthlyIncome;
    
    // Scoring:
    // DTI < 30% -> Excellent (100)
    // DTI < 40% -> Good (80)
    // DTI < 50% -> Fair (60)
    // DTI > 50% -> Poor (< 40)
    
    if (dti <= 0.3) return 100;
    if (dti <= 0.4) return 80;
    if (dti <= 0.5) return 60;
    
    // Linear decay from 60 to 0 as DTI goes from 0.5 to 1.0
    double score = 60 - ((dti - 0.5) / 0.5) * 60;
    return score.clamp(0, 60);
  }

  double _calculateSavingsScore(FinancialContextService context) {
    double income = context.totalMonthlyIncome.value;
    double savings = context.averageMonthlySavings.value; // Net income proxy

    if (income == 0) return 50.0;

    double rate = savings / income;
    // Target 20%
    if (rate >= 0.2) return 100;
    if (rate <= 0) return 0; // Dis-saving

    return (rate / 0.2) * 100;
  }

  double _calculateEmergencyScore(FinancialContextService context) {
    double liquidAssets = context.currentBalance.value;
    
    // Subtract imminent debt obligations (min payments) to get "Real" liquid assets
    liquidAssets -= context.totalMonthlyDebtPayments.value;

    // Calculate average monthly expenses (last 3 full months)
    // We skip current month to avoid volatility
    final now = DateTime.now();
    double totalExpenses = 0.0;
    int monthsCounted = 0;

    for (int i = 1; i <= 3; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final start = DateTime(targetMonth.year, targetMonth.month, 1);
      final end = DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

      final monthlyExpense = context.allTransactions
          .where((tx) => 
              tx.type == TransactionType.expense && 
              tx.date.isAfter(start) && 
              tx.date.isBefore(end))
          .fold(0.0, (sum, tx) => sum + tx.amount);

      if (monthlyExpense > 0) {
        totalExpenses += monthlyExpense;
        monthsCounted++;
      }
    }

    double avgExpenses = monthsCounted > 0 
        ? totalExpenses / monthsCounted 
        : context.totalMonthlyExpenses.value; // Fallback to current if no history

    if (avgExpenses == 0) return liquidAssets > 0 ? 100 : 50;

    double monthsCovered = liquidAssets / avgExpenses;
    // Target 3-6 months
    if (monthsCovered >= 6) return 100;
    if (monthsCovered >= 3) return 80 + (monthsCovered - 3) / 3 * 20; // 80-100
    
    // 0 to 3 months -> 0 to 80 score
    return (monthsCovered / 3) * 80;
  }
}

class FinancialHealthScore {
  final int totalScore;
  final List<HealthFactor> factors;
  final DateTime calculatedAt;

  FinancialHealthScore({
    required this.totalScore,
    required this.factors,
    required this.calculatedAt,
  });

  String get level {
    if (totalScore >= 80) return 'Excellent';
    if (totalScore >= 60) return 'Bon';
    if (totalScore >= 40) return 'Moyen';
    return 'Fragile';
  }
}

class HealthFactor {
  final String name;
  final double score;
  final double weight;
  final String description;

  HealthFactor({
    required this.name,
    required this.score,
    required this.weight,
    required this.description,
  });
}
