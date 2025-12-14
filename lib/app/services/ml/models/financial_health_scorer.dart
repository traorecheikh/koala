import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:logger/logger.dart';

/// Enhanced Financial Health Scorer with intelligent behavioral analysis
/// Detects: reckless spending, debt overload, lending risk, spending velocity
class FinancialHealthScorer {
  final _logger = Logger();

  FinancialHealthScore calculateScore({
    required FinancialContextService context,
    required UserFinancialProfile profile,
  }) {
    _logger.d('═══════════════════════════════════════════════════════');
    _logger.d('       CALCULATING ENHANCED FINANCIAL HEALTH SCORE       ');
    _logger.d('═══════════════════════════════════════════════════════');

    double totalScore = 0;
    final factors = <HealthFactor>[];
    final penalties = <HealthPenalty>[];

    final monthlyIncome = context.totalMonthlyIncome.value;
    _logger.d('Monthly Income: $monthlyIncome FCFA');

    // ═══════════════════════════════════════════════════════════════════
    // 1. BUDGET ADHERENCE (15%) - Enhanced with overspending severity
    // ═══════════════════════════════════════════════════════════════════
    final budgetResult = _calculateBudgetScore(context);
    _logger.d(
        'Budget Score: ${budgetResult.score} (Overspent categories: ${budgetResult.overSpentCount})');
    factors.add(HealthFactor(
      name: 'Budgets',
      score: budgetResult.score,
      weight: 0.15,
      description: budgetResult.overSpentCount > 0
          ? '${budgetResult.overSpentCount} catégorie(s) dépassée(s)'
          : 'Budgets respectés',
    ));
    totalScore += budgetResult.score * 0.15;

    // ═══════════════════════════════════════════════════════════════════
    // 2. GOAL PROGRESS (15%)
    // ═══════════════════════════════════════════════════════════════════
    double goalScore = _calculateGoalScore(context);
    _logger.d('Goal Score: $goalScore');
    factors.add(HealthFactor(
      name: 'Objectifs',
      score: goalScore,
      weight: 0.15,
      description: 'Progression des objectifs',
    ));
    totalScore += goalScore * 0.15;

    // ═══════════════════════════════════════════════════════════════════
    // 3. DEBT HEALTH (20%) - Enhanced with total debt + monthly payments
    // ═══════════════════════════════════════════════════════════════════
    final debtResult = _calculateEnhancedDebtScore(context, monthlyIncome);
    _logger.d(
        'Debt Score: ${debtResult.score} (DTI: ${debtResult.dti.toStringAsFixed(1)}%, Total Debt Ratio: ${debtResult.totalDebtRatio.toStringAsFixed(1)}x)');
    factors.add(HealthFactor(
      name: 'Dettes',
      score: debtResult.score,
      weight: 0.20,
      description: debtResult.description,
    ));
    totalScore += debtResult.score * 0.20;
    if (debtResult.penalty != null) penalties.add(debtResult.penalty!);

    // ═══════════════════════════════════════════════════════════════════
    // 4. LENDING RISK (NEW - 5%) - Money you lent that might not come back
    // ═══════════════════════════════════════════════════════════════════
    final lendingResult = _calculateLendingRisk(context, monthlyIncome);
    _logger.d(
        'Lending Risk Score: ${lendingResult.score} (Lent: ${lendingResult.totalLent} FCFA)');
    factors.add(HealthFactor(
      name: 'Prêts',
      score: lendingResult.score,
      weight: 0.05,
      description: lendingResult.description,
    ));
    totalScore += lendingResult.score * 0.05;
    if (lendingResult.penalty != null) penalties.add(lendingResult.penalty!);

    // ═══════════════════════════════════════════════════════════════════
    // 5. SAVINGS RATE (15%)
    // ═══════════════════════════════════════════════════════════════════
    double savingsScore = _calculateSavingsScore(context);
    _logger.d('Savings Score: $savingsScore');
    factors.add(HealthFactor(
      name: 'Épargne',
      score: savingsScore,
      weight: 0.15,
      description: 'Capacité d\'épargne mensuelle',
    ));
    totalScore += savingsScore * 0.15;

    // ═══════════════════════════════════════════════════════════════════
    // 6. SPENDING BEHAVIOR (NEW - 15%) - Reckless transactions + velocity
    // ═══════════════════════════════════════════════════════════════════
    final behaviorResult = _calculateSpendingBehavior(context, monthlyIncome);
    _logger.d('Behavior Score: ${behaviorResult.score}');
    _logger.d('  - Reckless transactions: ${behaviorResult.recklessCount}');
    _logger.d(
        '  - Spending velocity: ${behaviorResult.velocityPercent.toStringAsFixed(0)}% in first 10 days');
    factors.add(HealthFactor(
      name: 'Comportement',
      score: behaviorResult.score,
      weight: 0.15,
      description: behaviorResult.description,
    ));
    totalScore += behaviorResult.score * 0.15;
    penalties.addAll(behaviorResult.penalties);

    // ═══════════════════════════════════════════════════════════════════
    // 7. EMERGENCY FUND (15%)
    // ═══════════════════════════════════════════════════════════════════
    double emergencyScore = _calculateEmergencyScore(context);
    _logger.d('Emergency Fund Score: $emergencyScore');
    factors.add(HealthFactor(
      name: 'Sécurité',
      score: emergencyScore,
      weight: 0.15,
      description: 'Fonds d\'urgence disponible',
    ));
    totalScore += emergencyScore * 0.15;

    // ═══════════════════════════════════════════════════════════════════
    // APPLY PENALTIES (hard caps for severe issues)
    // ═══════════════════════════════════════════════════════════════════
    double penaltyDeduction = 0;
    for (var penalty in penalties) {
      penaltyDeduction += penalty.points;
      _logger.w('PENALTY: ${penalty.reason} (-${penalty.points} points)');
    }

    totalScore -= penaltyDeduction;
    totalScore = totalScore.clamp(0, 100);

    _logger.i('═══════════════════════════════════════════════════════');
    _logger.i('FINAL HEALTH SCORE: ${totalScore.round()}/100');
    _logger
        .i('Penalties applied: ${penalties.length} (-$penaltyDeduction pts)');
    _logger.i('═══════════════════════════════════════════════════════');

    return FinancialHealthScore(
      totalScore: totalScore.round(),
      factors: factors,
      penalties: penalties,
      calculatedAt: DateTime.now(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ENHANCED BUDGET SCORE - Penalizes proportionally to overspending
  // ═══════════════════════════════════════════════════════════════════════
  _BudgetScoreResult _calculateBudgetScore(FinancialContextService context) {
    if (context.allBudgets.isEmpty) {
      return _BudgetScoreResult(score: 50.0, overSpentCount: 0);
    }

    final now = DateTime.now();
    final currentBudgets = context.allBudgets
        .where((b) => b.year == now.year && b.month == now.month)
        .toList();

    if (currentBudgets.isEmpty) {
      return _BudgetScoreResult(score: 50.0, overSpentCount: 0);
    }

    double totalBudgetScore = 0;
    int overSpentCount = 0;

    for (var budget in currentBudgets) {
      final spent = context.getSpentAmountForCategory(
          budget.categoryId, now.year, now.month);
      final ratio = spent / (budget.amount == 0 ? 1 : budget.amount);

      if (ratio <= 0.8) {
        // Under 80% - Excellent (100 pts for this budget)
        totalBudgetScore += 100;
      } else if (ratio <= 1.0) {
        // 80-100% - Good but warning (80 pts)
        totalBudgetScore += 80;
      } else if (ratio <= 1.2) {
        // 100-120% - Over budget (50 pts)
        totalBudgetScore += 50;
        overSpentCount++;
      } else if (ratio <= 1.5) {
        // 120-150% - Significantly over (25 pts)
        totalBudgetScore += 25;
        overSpentCount++;
      } else {
        // >150% - Severely over (0 pts)
        totalBudgetScore += 0;
        overSpentCount++;
      }
    }

    final avgScore = totalBudgetScore / currentBudgets.length;
    return _BudgetScoreResult(score: avgScore, overSpentCount: overSpentCount);
  }

  double _calculateGoalScore(FinancialContextService context) {
    final activeGoals =
        context.allGoals.where((g) => g.status == GoalStatus.active).toList();
    if (activeGoals.isEmpty) return 50.0;

    double totalProgress = 0;
    for (var goal in activeGoals) {
      totalProgress += goal.progressPercentage;
    }

    return (totalProgress / activeGoals.length).clamp(0, 100);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ENHANCED DEBT SCORE - Considers BOTH monthly payments AND total debt
  // ═══════════════════════════════════════════════════════════════════════
  _DebtScoreResult _calculateEnhancedDebtScore(
      FinancialContextService context, double monthlyIncome) {
    final monthlyDebt = context.totalMonthlyDebtPayments.value;
    final totalOutstanding = context.totalOutstandingDebt.value;

    if (monthlyIncome == 0) {
      if (totalOutstanding > 0) {
        return _DebtScoreResult(
          score: 0,
          dti: 100,
          totalDebtRatio: 999,
          description: 'Dettes sans revenu',
          penalty:
              HealthPenalty(reason: 'Dettes sans source de revenu', points: 20),
        );
      }
      return _DebtScoreResult(
          score: 50, dti: 0, totalDebtRatio: 0, description: 'Pas de dette');
    }

    // 1. Debt-to-Income ratio (monthly payments / monthly income)
    final dti = (monthlyDebt / monthlyIncome) * 100;

    // 2. Total debt to annual income ratio
    final annualIncome = monthlyIncome * 12;
    final totalDebtRatio =
        annualIncome > 0 ? totalOutstanding / annualIncome : 0.0;

    // Calculate DTI score (0-60 points max)
    double dtiScore;
    if (dti <= 20) {
      dtiScore = 60; // Excellent
    } else if (dti <= 35) {
      dtiScore = 50; // Good
    } else if (dti <= 50) {
      dtiScore = 35; // Concerning
    } else {
      dtiScore = 20 - ((dti - 50) / 50 * 20).clamp(0, 20); // Bad to Critical
    }

    // Calculate Total Debt score (0-40 points max)
    double totalDebtScore;
    if (totalDebtRatio <= 1) {
      totalDebtScore = 40; // Less than 1 year income - manageable
    } else if (totalDebtRatio <= 2) {
      totalDebtScore = 30; // 1-2 years income - concerning
    } else if (totalDebtRatio <= 3) {
      totalDebtScore = 15; // 2-3 years income - risky
    } else {
      totalDebtScore = 0; // >3 years income - critical
    }

    final combinedScore = (dtiScore + totalDebtScore).clamp(0, 100).toDouble();

    // Penalty for excessive total debt
    HealthPenalty? penalty;
    if (totalDebtRatio > 3) {
      penalty = HealthPenalty(
        reason:
            'Endettement excessif (>${(totalDebtRatio).toStringAsFixed(1)}x revenu annuel)',
        points: 10,
      );
    }

    String description;
    if (combinedScore >= 80) {
      description = 'Dettes bien maîtrisées';
    } else if (combinedScore >= 50) {
      description = 'Niveau de dette acceptable';
    } else if (combinedScore >= 30) {
      description = 'Attention à l\'endettement';
    } else {
      description = 'Surcharge de dettes';
    }

    return _DebtScoreResult(
      score: combinedScore,
      dti: dti,
      totalDebtRatio: totalDebtRatio,
      description: description,
      penalty: penalty,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NEW: LENDING RISK - Money you lent to others
  // ═══════════════════════════════════════════════════════════════════════
  _LendingRiskResult _calculateLendingRisk(
      FinancialContextService context, double monthlyIncome) {
    // Get all "lent" type debts (money others owe you)
    final lentDebts = context.allDebts
        .where((d) => d.type == DebtType.lent && !d.isPaidOff)
        .toList();

    if (lentDebts.isEmpty) {
      return _LendingRiskResult(
          score: 100, totalLent: 0, description: 'Aucun prêt en cours');
    }

    final totalLent = lentDebts.fold(0.0, (sum, d) => sum + d.remainingAmount);

    if (monthlyIncome == 0) {
      return _LendingRiskResult(
        score: totalLent > 0 ? 30 : 100,
        totalLent: totalLent,
        description: 'Prêts sans revenu stable',
      );
    }

    // Risk assessment: how much of your income is "at risk"
    final lentRatio = totalLent / monthlyIncome;

    double score;
    String description;
    HealthPenalty? penalty;

    if (lentRatio <= 0.5) {
      score = 100;
      description = 'Prêts raisonnables';
    } else if (lentRatio <= 1) {
      score = 80;
      description = 'Prêts modérés';
    } else if (lentRatio <= 2) {
      score = 50;
      description = 'Beaucoup prêté';
    } else {
      score = 20;
      description = 'Trop prêté - risque élevé';
      penalty = HealthPenalty(
        reason:
            'Prêts excessifs (${lentRatio.toStringAsFixed(1)}x revenu mensuel)',
        points: 5,
      );
    }

    // Check for overdue loans
    final overdueCount = lentDebts
        .where((d) => d.dueDate != null && d.dueDate!.isBefore(DateTime.now()))
        .length;
    if (overdueCount > 0) {
      score -= 15;
      description = '$overdueCount prêt(s) en retard';
    }

    return _LendingRiskResult(
      score: score.clamp(0, 100),
      totalLent: totalLent,
      description: description,
      penalty: penalty,
    );
  }

  double _calculateSavingsScore(FinancialContextService context) {
    final income = context.totalMonthlyIncome.value;
    final savings = context.averageMonthlySavings.value;

    if (income == 0) return 50.0;

    final rate = savings / income;
    if (rate >= 0.2) return 100;
    if (rate <= 0) return 0;
    return (rate / 0.2) * 100;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // NEW: SPENDING BEHAVIOR - Reckless transactions + velocity
  // ═══════════════════════════════════════════════════════════════════════
  _SpendingBehaviorResult _calculateSpendingBehavior(
      FinancialContextService context, double monthlyIncome) {
    final penalties = <HealthPenalty>[];
    double score = 100;

    if (monthlyIncome == 0) {
      return _SpendingBehaviorResult(
        score: 50,
        recklessCount: 0,
        velocityPercent: 0,
        description: 'Pas assez de données',
        penalties: [],
      );
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Get this month's expenses
    final thisMonthExpenses = context.allTransactions
        .where((tx) =>
            tx.type == TransactionType.expense &&
            tx.date.isAfter(monthStart) &&
            tx.date.isBefore(now.add(const Duration(days: 1))))
        .toList();

    // ═══════════════════════════════════════════════════════════════
    // 1. RECKLESS TRANSACTION DETECTION
    // A single transaction > 30% of monthly income is reckless
    // ═══════════════════════════════════════════════════════════════
    final recklessThreshold = monthlyIncome * 0.30;
    final recklessTransactions =
        thisMonthExpenses.where((tx) => tx.amount > recklessThreshold).toList();
    final recklessCount = recklessTransactions.length;

    if (recklessCount > 0) {
      final penaltyPoints = (recklessCount * 10).clamp(0, 30);
      score -= penaltyPoints;
      penalties.add(HealthPenalty(
        reason: '$recklessCount dépense(s) impulsive(s) (>30% du revenu)',
        points: penaltyPoints.toDouble(),
      ));
    }

    // ═══════════════════════════════════════════════════════════════
    // 2. SPENDING VELOCITY - How fast are you spending?
    // If you spend >50% of income in first 10 days = bad
    // ═══════════════════════════════════════════════════════════════
    final tenthOfMonth = DateTime(now.year, now.month, 10);
    final first10DaysExpenses = thisMonthExpenses
        .where((tx) => tx.date.isBefore(tenthOfMonth))
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final velocityPercent =
        monthlyIncome > 0 ? (first10DaysExpenses / monthlyIncome) * 100 : 0.0;

    if (velocityPercent > 70) {
      // Spent >70% in first 10 days - critical
      score -= 25;
      penalties.add(HealthPenalty(
        reason:
            '${velocityPercent.toStringAsFixed(0)}% du revenu dépensé en 10 jours',
        points: 15,
      ));
    } else if (velocityPercent > 50) {
      // Spent >50% in first 10 days - warning
      score -= 10;
    }

    // ═══════════════════════════════════════════════════════════════
    // 3. DAILY SPENDING SPIKES
    // Multiple large expenses on same day is suspicious
    // ═══════════════════════════════════════════════════════════════
    final expensesByDay = <String, double>{};
    for (var tx in thisMonthExpenses) {
      final dayKey = '${tx.date.year}-${tx.date.month}-${tx.date.day}';
      expensesByDay[dayKey] = (expensesByDay[dayKey] ?? 0) + tx.amount;
    }

    final dailyThreshold = monthlyIncome * 0.25; // 25% of income in one day
    final spikeDays =
        expensesByDay.values.where((v) => v > dailyThreshold).length;

    if (spikeDays > 2) {
      score -= 10;
    }

    // Build description
    String description;
    if (score >= 80) {
      description = 'Dépenses équilibrées';
    } else if (score >= 50) {
      description = 'Quelques excès détectés';
    } else {
      description = 'Comportement impulsif';
    }

    return _SpendingBehaviorResult(
      score: score.clamp(0, 100),
      recklessCount: recklessCount,
      velocityPercent: velocityPercent,
      description: description,
      penalties: penalties,
    );
  }

  double _calculateEmergencyScore(FinancialContextService context) {
    double liquidAssets = context.currentBalance.value;
    liquidAssets -= context.totalMonthlyDebtPayments.value;

    final now = DateTime.now();
    double totalExpenses = 0.0;
    int monthsCounted = 0;

    for (int i = 1; i <= 3; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final start = DateTime(targetMonth.year, targetMonth.month, 1);
      final end =
          DateTime(targetMonth.year, targetMonth.month + 1, 0, 23, 59, 59);

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
        : context.totalMonthlyExpenses.value;

    if (avgExpenses == 0) return liquidAssets > 0 ? 100 : 50;

    double monthsCovered = liquidAssets / avgExpenses;
    if (monthsCovered >= 6) return 100;
    if (monthsCovered >= 3) return 80 + (monthsCovered - 3) / 3 * 20;
    return (monthsCovered / 3) * 80;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class _BudgetScoreResult {
  final double score;
  final int overSpentCount;
  _BudgetScoreResult({required this.score, required this.overSpentCount});
}

class _DebtScoreResult {
  final double score;
  final double dti;
  final double totalDebtRatio;
  final String description;
  final HealthPenalty? penalty;
  _DebtScoreResult({
    required this.score,
    required this.dti,
    required this.totalDebtRatio,
    required this.description,
    this.penalty,
  });
}

class _LendingRiskResult {
  final double score;
  final double totalLent;
  final String description;
  final HealthPenalty? penalty;
  _LendingRiskResult({
    required this.score,
    required this.totalLent,
    required this.description,
    this.penalty,
  });
}

class _SpendingBehaviorResult {
  final double score;
  final int recklessCount;
  final double velocityPercent;
  final String description;
  final List<HealthPenalty> penalties;
  _SpendingBehaviorResult({
    required this.score,
    required this.recklessCount,
    required this.velocityPercent,
    required this.description,
    required this.penalties,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// PUBLIC CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class FinancialHealthScore {
  final int totalScore;
  final List<HealthFactor> factors;
  final List<HealthPenalty> penalties;
  final DateTime calculatedAt;

  FinancialHealthScore({
    required this.totalScore,
    required this.factors,
    required this.penalties,
    required this.calculatedAt,
  });

  String get level {
    if (totalScore >= 80) return 'Excellent';
    if (totalScore >= 60) return 'Bon';
    if (totalScore >= 40) return 'Moyen';
    return 'Fragile';
  }

  String get emoji {
    if (totalScore >= 80) return '🟢';
    if (totalScore >= 60) return '🟡';
    if (totalScore >= 40) return '🟠';
    return '🔴';
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

class HealthPenalty {
  final String reason;
  final double points;

  HealthPenalty({required this.reason, required this.points});
}

