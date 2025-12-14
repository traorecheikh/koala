// ══════════════════════════════════════════════════════════════════════════
// DATA MODELS (Retained/Adapted)
// ══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class ProactiveAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String actionSuggestion;
  final dynamic icon;

  ProactiveAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.actionSuggestion = '',
    this.icon,
  });
}

enum AlertSeverity { critical, high, medium, low, positive, info }

class CategorySuggestion {
  final String? categoryId;
  final String? categoryName;
  final double confidence;

  CategorySuggestion({this.categoryId, this.categoryName, required this.confidence});
}

class CashFlowForecast {
  final ForecastSummary summary;
  final List<dynamic> dailyBalances;

  CashFlowForecast({required this.summary, required this.dailyBalances});
}

class ForecastSummary {
  final double endBalance;
  final double lowestBalance;
  final DateTime? lowestBalanceDate;
  final RiskLevel riskLevel;

  ForecastSummary({
    required this.endBalance,
    required this.lowestBalance,
    this.lowestBalanceDate,
    required this.riskLevel,
  });
}

enum RiskLevel { critical, high, medium, low, unknown }

class SmartBudget {
  final double recommendedAmount;
  final double percentOfIncome;
  
  SmartBudget(this.recommendedAmount, this.percentOfIncome);
}

class GoalFeasibility {
  final FeasibilityLevel feasibilityLevel;
  final double currentMonthlySavings;
  
  GoalFeasibility(this.feasibilityLevel, this.currentMonthlySavings);
}

enum FeasibilityLevel { realistic, challenging, unrealistic }

class IntelligenceSummary {
  final RiskLevel riskLevel;
  final int criticalAlertsCount;
  final int warningAlertsCount;
  final int positiveAlertsCount;
  final double predictedEndBalance;
  final double lowestPredictedBalance;
  final double savingsRate;
  final ProactiveAlert? topAlert;
  final int healthScore;

  IntelligenceSummary({
    required this.riskLevel,
    required this.criticalAlertsCount,
    required this.warningAlertsCount,
    required this.positiveAlertsCount,
    required this.predictedEndBalance,
    required this.lowestPredictedBalance,
    required this.savingsRate,
    this.topAlert,
    required this.healthScore,
  });

  String get statusEmoji {
    if (healthScore >= 80) return '🟢';
    if (healthScore >= 60) return '🟡';
    if (healthScore >= 40) return '🟠';
    return '🔴';
  }

  String get statusText {
    if (healthScore >= 80) return 'Excellent';
    if (healthScore >= 60) return 'Bon';
    if (healthScore >= 40) return 'Attention';
    return 'Critique';
  }

  String get statusDescription {
    if (healthScore >= 80) return 'Vos finances sont en excellente santé !';
    if (healthScore >= 60) return 'Vos finances vont bien, quelques points d\'attention.';
    if (healthScore >= 40) return 'Surveillez vos dépenses, des ajustements sont nécessaires.';
    return 'Situation critique, action immédiate recommandée.';
  }
}

class IntelligenceService extends GetxService {
  final isLoading = false.obs;
  final forecast = Rxn<CashFlowForecast>();
  final RxList<ProactiveAlert> highPriorityAlerts = <ProactiveAlert>[].obs;

  late IntelligenceSummary _summary;

  @override
  Future<void> onInit() async {
    super.onInit();
    _summary = IntelligenceSummary(
      riskLevel: RiskLevel.unknown,
      criticalAlertsCount: 0,
      warningAlertsCount: 0,
      positiveAlertsCount: 0,
      predictedEndBalance: 0.0,
      lowestPredictedBalance: 0.0,
      savingsRate: 0.0,
      topAlert: null,
      healthScore: 100,
    );
    isLoading.value = false;
    return;
  }

  IntelligenceSummary getSummary() => _summary;

  Future<void> forceRefresh() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 50));
    isLoading.value = false;
  }

  void dismissAlert(String id) {
    highPriorityAlerts.removeWhere((a) => a.id == id);
  }
}
