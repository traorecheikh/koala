import 'dart:math';

import 'package:koaa/app/data/models/ml/financial_pattern.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/data/models/financial_goal.dart'; // New import
import 'package:koaa/app/data/models/budget.dart'; // New import
import 'package:koaa/app/data/models/debt.dart'; // New import
import 'package:koaa/app/services/financial_context_service.dart'; // New import
import 'package:koaa/app/services/ml/models/anomaly_detector.dart';
import 'package:koaa/app/services/ml/models/behavior_profiler.dart';
import 'package:koaa/app/services/ml/models/financial_health_scorer.dart';
import 'package:koaa/app/services/ml/models/pattern_recognizer.dart';
import 'package:koaa/app/services/ml/models/time_series_engine.dart';

/// Context-aware insight generator
/// Creates personalized, emotionally intelligent financial advice
class InsightGenerator {
  final BehaviorProfiler _profiler;

  InsightGenerator(this._profiler);

  /// Generate prioritized insights based on full context
  List<MLInsight> generateInsights({
    required UserFinancialProfile profile,
    required List<FinancialPattern> patterns,
    required List<SpendingAnomaly> anomalies,
    required ForecastResult? forecast,
    required FinancialHealthScore health,
    required FinancialContextService context, // New parameter
  }) {
    final insights = <MLInsight>[];

    // 1. Critical Alerts (Immediate action needed)
    _addAnomalyInsights(insights, anomalies, profile);
    _addForecastAlerts(insights, forecast);

    // 2. Cross-Feature Insights (Holistic view)
    _addCrossFeatureInsights(insights, context);

    // 3. Persona-based Coaching (Long-term behavioral change)
    _addPersonaCoaching(insights, profile);

    // 4. Pattern-based Insights (Operational improvements)
    _addPatternInsights(insights, patterns);

    // 5. Health-based Celebration/Warning (Motivation)
    _addHealthInsights(insights, health);

    // Sort by priority and limit to top 5 to avoid overwhelming user
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights.take(5).toList();
  }

  void _addCrossFeatureInsights(List<MLInsight> insights, FinancialContextService context) {
    // 1. Budget Surplus -> Goal Contribution
    final now = DateTime.now();
    for (var budget in context.allBudgets) {
      if (budget.year == now.year && budget.month == now.month) {
        final spent = context.getSpentAmountForCategory(budget.categoryId, now.year, now.month);
        final remaining = budget.amount - spent;
        
        // If > 20% remaining and we are past day 25
        if (remaining > budget.amount * 0.2 && now.day > 25) {
          final category = context.getCategoryById(budget.categoryId);
          insights.add(MLInsight(
            id: 'budget_surplus_${budget.id}',
            title: 'Surplus budgétaire : ${category?.name ?? "Catégorie"}',
            description: 'Il vous reste ${remaining.toStringAsFixed(0)} FCFA dans ce budget. Pourquoi ne pas l\'ajouter à un objectif ?',
            type: InsightType.positive,
            priority: 8,
            actionLabel: 'Verser sur un objectif',
          ));
        }
      }
    }

    // 2. Debt vs Savings
    final totalSavings = context.currentBalance.value; // Simplification
    final debts = context.getActiveDebts();
    if (debts.isNotEmpty && totalSavings > 0) {
      final highInterestDebt = debts.first; // Ideally pick highest interest
      if (totalSavings > highInterestDebt.remainingAmount) {
         insights.add(MLInsight(
            id: 'debt_payoff_opportunity',
            title: 'Opportunité de remboursement',
            description: 'Vous avez assez de liquidités pour rembourser "${highInterestDebt.personName}". Cela réduirait vos engagements mensuels.',
            type: InsightType.info,
            priority: 7,
            actionLabel: 'Simuler le remboursement',
          ));
      }
    }

    // 3. Goal Progress Velocity
    final activeGoals = context.allGoals.where((g) => g.status == GoalStatus.active);
    for (var goal in activeGoals) {
      final monthlySavings = context.averageMonthlySavings.value;
      if (monthlySavings > 0 && goal.targetAmount > goal.currentAmount) {
        final months = (goal.targetAmount - goal.currentAmount) / monthlySavings;
        if (months < 2) {
           insights.add(MLInsight(
            id: 'goal_close_${goal.id}',
            title: 'Objectif "${goal.title}" en vue !',
            description: 'À ce rythme, vous pourriez l\'atteindre dans moins de 2 mois.',
            type: InsightType.positive,
            priority: 6,
          ));
        }
      }
    }
  }

  void _addAnomalyInsights(
    List<MLInsight> insights,
    List<SpendingAnomaly> anomalies,
    UserFinancialProfile profile,
  ) {
    for (final anomaly in anomalies) {
      if (anomaly.severity == AnomalySeverity.high) {
        insights.add(MLInsight(
          id: 'anomaly_${anomaly.date.millisecondsSinceEpoch}',
          title: 'Dépense inhabituelle',
          description: _getAnomalyMessage(anomaly, profile),
          type: InsightType.warning,
          priority: 10,
          actionLabel: 'Voir le détail',
          relatedData: {'anomaly_amount': anomaly.amount},
        ));
      }
    }
  }

  String _getAnomalyMessage(SpendingAnomaly anomaly, UserFinancialProfile profile) {
    // Adjust tone based on persona
    if (profile.personaType == FinancialPersona.saver.name) {
      return 'Attention, cette dépense de ${anomaly.amount.toStringAsFixed(0)} FCFA sort de vos habitudes strictes.';
    } else if (profile.personaType == FinancialPersona.spender.name) {
      return 'Oups ! Une dépense de ${anomaly.amount.toStringAsFixed(0)} FCFA a été détectée. Était-ce prévu ?';
    }
    return 'Dépense de ${anomaly.amount.toStringAsFixed(0)} FCFA détectée, bien au-dessus de la moyenne pour ${anomaly.categoryName}.';
  }

  void _addForecastAlerts(List<MLInsight> insights, ForecastResult? forecast) {
    if (forecast == null) return;

    if (forecast.riskLevel == ForecastRiskLevel.high) {
      insights.add(MLInsight(
        id: 'forecast_risk_high',
        title: 'Risque de fin de mois difficile',
        description: 'D\'après nos prévisions, vous pourriez manquer de liquidités dans environ ${forecast.daysUntilZero ?? 5} jours.',
        type: InsightType.warning,
        priority: 9,
        actionLabel: 'Réduire les dépenses',
      ));
    }
  }

  void _addPersonaCoaching(List<MLInsight> insights, UserFinancialProfile profile) {
    // We don't have a 'confidence' field in UserFinancialProfile yet, simplified for now
    
    final adviceList = _profiler.getAdviceForPersona(profile.personaType);
    if (adviceList.isEmpty) return;

    // Pick one random advice from the list to keep it fresh
    final advice = adviceList[Random().nextInt(adviceList.length)];

    insights.add(MLInsight(
      id: 'persona_coaching_${DateTime.now().day}', // Changes daily
      title: 'Conseil personnalisé',
      description: advice,
      type: InsightType.tip,
      priority: 5,
    ));
  }

  void _addPatternInsights(List<MLInsight> insights, List<FinancialPattern> patterns) {
    // Recurring expenses
    final recurringCount = patterns.where((p) => p.patternType == PatternType.recurringExpense.name).length;
    if (recurringCount > 5) {
      insights.add(MLInsight(
        id: 'pattern_subscriptions',
        title: 'Accumulation d\'abonnements',
        description: 'Vous avez $recurringCount paiements récurrents identifiés. Vérifiez si vous les utilisez tous.',
        type: InsightType.tip,
        priority: 4,
      ));
    }

    // End of month squeeze
    final squeeze = patterns.any((p) => 
        p.patternType == PatternType.monthlyCycle.name && 
        p.parameters['pattern'] == 'end_of_month_squeeze');
    
    if (squeeze) {
      final daysToMonthEnd = 30 - DateTime.now().day;
      if (daysToMonthEnd < 10 && daysToMonthEnd > 0) {
        insights.add(MLInsight(
          id: 'pattern_squeeze',
          title: 'Fin de mois approche',
          description: 'Historiquement, vos dépenses augmentent cette semaine. Gardez le cap !',
          type: InsightType.info,
          priority: 6,
        ));
      }
    }
    
    // Merchant habit
    // Need extension to find specific element
    FinancialPattern? topMerchant;
    for (var p in patterns) {
       if (p.patternType == PatternType.merchantHabit.name) {
         topMerchant = p;
         break; 
       }
    }

    if (topMerchant != null) {
      final name = topMerchant.parameters['merchantName'];
      final visits = topMerchant.parameters['visitsPerMonth'];
      // parameters values are Strings because of Hive fix
      final visitsNum = double.tryParse(visits?.toString() ?? '0') ?? 0;
      
      if (visitsNum > 4) {
         insights.add(MLInsight(
          id: 'pattern_merchant_$name',
          title: 'Client fidèle chez $name',
          description: 'Vous y allez environ ${visitsNum.toStringAsFixed(0)} fois par mois. Avez-vous une carte de fidélité ?',
          type: InsightType.tip,
          priority: 3,
        ));
      }
    }
  }

  void _addHealthInsights(List<MLInsight> insights, FinancialHealthScore health) {
    if (health.totalScore > 80) {
      insights.add(MLInsight(
        id: 'health_excellent',
        title: 'Santé financière au top !',
        description: 'Votre score est excellent (${health.totalScore}/100). C\'est le moment de penser à investir.',
        type: InsightType.positive,
        priority: 7,
      ));
    } else {
      // Find low factor
      HealthFactor? lowFactor;
      for (var f in health.factors) {
        if (f.name == 'Épargne' && f.score < 30) {
          lowFactor = f;
          break;
        }
      }

      if (lowFactor != null) {
        insights.add(MLInsight(
          id: 'health_savings_low',
          title: 'Booster votre épargne',
          description: 'Votre taux d\'épargne est faible. Essayez de mettre de côté dès la réception de vos revenus.',
          type: InsightType.tip,
          priority: 6,
        ));
      }
    }
  }
}

class MLInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final int priority;
  final String? actionLabel;
  final Map<String, dynamic>? relatedData;

  MLInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.actionLabel,
    this.relatedData,
  });
}

enum InsightType { positive, warning, tip, info }
