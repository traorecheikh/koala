import 'dart:math';

import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/savings_goal.dart';

class GoalOptimizer {
  GoalOptimizer();

  List<OptimizationSuggestion> optimizeGoals(
      List<SavingsGoal> goals, List<LocalTransaction> history) {
    if (goals.isEmpty) return [];

    final suggestions = <OptimizationSuggestion>[];

    // 1. Calculate average monthly savings capacity
    final monthlySavings = _calculateAverageMonthlySavings(history);

    // 2. Calculate required monthly savings for all goals
    double totalRequired = 0;
    for (final goal in goals) {
      final monthsLeft = _monthsUntil(goal.year, goal.month);
      if (monthsLeft > 0) {
        // Assume currentAmount is 0 for simplicity or fetch it (missing in SavingsGoal model in snippet)
        // Let's assume we need to save the full targetAmount from now
        totalRequired += goal.targetAmount / monthsLeft;
      }
    }

    // 3. Compare
    if (totalRequired > monthlySavings * 1.1) {
      // Unrealistic

      suggestions.add(OptimizationSuggestion(
        title: 'Objectifs ambitieux',
        description:
            'Vous visez ${totalRequired.toStringAsFixed(0)} FCFA/mois, mais votre moyenne est de ${monthlySavings.toStringAsFixed(0)} FCFA.',
        action: 'Ajuster les échéances',
        type: SuggestionType.adjustment,
      ));
    } else if (monthlySavings > totalRequired * 1.5) {
      // Too easy
      suggestions.add(OptimizationSuggestion(
        title: 'Potentiel inexploité',
        description: 'Vous pourriez atteindre vos objectifs plus vite !',
        action: 'Raccourcir les délais',
        type: SuggestionType.opportunity,
      ));
    }

    return suggestions;
  }

  double _calculateAverageMonthlySavings(List<LocalTransaction> history) {
    // Simple: Income - Expense averaged over months
    if (history.isEmpty) return 0;

    // Group by month
    final monthlyNet = <String, double>{};
    for (var tx in history) {
      final key = '${tx.date.year}-${tx.date.month}';
      final amount = tx.type == TransactionType.income ? tx.amount : -tx.amount;
      monthlyNet[key] = (monthlyNet[key] ?? 0) + amount;
    }

    if (monthlyNet.isEmpty) return 0;

    final totalNet = monthlyNet.values.reduce((a, b) => a + b);
    return max(0, totalNet / monthlyNet.length);
  }

  int _monthsUntil(int year, int month) {
    final now = DateTime.now();
    final target = DateTime(year, month);
    final diff = target.difference(now).inDays / 30;
    return max(1, diff.ceil());
  }
}

class OptimizationSuggestion {
  final String title;
  final String description;
  final String action;
  final SuggestionType type;

  OptimizationSuggestion({
    required this.title,
    required this.description,
    required this.action,
    required this.type,
  });
}

enum SuggestionType { adjustment, opportunity, warning }
