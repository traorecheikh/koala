import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/data/models/savings_goal.dart';

class FinancialHealthScorer {
  FinancialHealthScore calculateScore({
    required List<LocalTransaction> transactions,
    required UserFinancialProfile profile,
    required List<SavingsGoal> goals,
  }) {
    double totalScore = 0;
    final factors = <HealthFactor>[];

    // 1. Savings Rate (20%)
    double savingsScore = (profile.savingsRate * 100).clamp(0, 100);
    // Adjust: 20% savings rate is considered "100/100" score for this metric?
    // Usually 20% is recommended. So rate / 0.2 * 100?
    // Let's say 20% savings = 100 pts.
    double normalizedSavings = (profile.savingsRate / 0.20) * 100;
    normalizedSavings = normalizedSavings.clamp(0, 100);
    
    factors.add(HealthFactor(
      name: 'Épargne',
      score: normalizedSavings,
      weight: 0.2,
      description: 'Capacité à mettre de côté',
    ));
    totalScore += normalizedSavings * 0.2;

    // 2. Spending Consistency (15%)
    double consistencyScore = (profile.consistencyScore * 100).clamp(0, 100);
    factors.add(HealthFactor(
      name: 'Stabilité',
      score: consistencyScore,
      weight: 0.15,
      description: 'Régularité des dépenses',
    ));
    totalScore += consistencyScore * 0.15;

    // 3. Goal Progress (10%)
    double goalScore = 0;
    if (goals.isNotEmpty) {
      // Logic to calculate goal progress
      goalScore = 50; // Placeholder
    } else {
      goalScore = 50; // Neutral if no goals
    }
    factors.add(HealthFactor(
      name: 'Objectifs',
      score: goalScore,
      weight: 0.1,
      description: 'Avancement des projets',
    ));
    totalScore += goalScore * 0.1;

    // 4. Emergency Buffer (20%) - Placeholder logic
    double bufferScore = 60; 
    factors.add(HealthFactor(
      name: 'Sécurité',
      score: bufferScore,
      weight: 0.2,
      description: 'Fonds d\'urgence',
    ));
    totalScore += bufferScore * 0.2;

    // Remaining 35%... for now distribute or assume 100
    // Simplify to sum of weights = 0.65 for now, rescale?
    // Let's add Debt/Bill reliability proxy
    
    // 5. Bill Reliability (Placeholder)
    double billScore = 80;
    factors.add(HealthFactor(
      name: 'Factures',
      score: billScore,
      weight: 0.35, // Remaining
      description: 'Paiement à temps',
    ));
    totalScore += billScore * 0.35;

    return FinancialHealthScore(
      totalScore: totalScore.round(),
      factors: factors,
      calculatedAt: DateTime.now(),
    );
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
