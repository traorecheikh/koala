import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/category_classifier.dart';

// Re-export specific ML types if needed by consumers
export 'package:koaa/app/services/ml/models/category_classifier.dart' show CategoryPrediction, PredictionSource;

/// Service that provides intelligent features across the app
/// Now powered by KoalaMLEngine (On-Device ML)
class IntelligenceService extends GetxService {
  KoalaMLEngine? _engine;
  
  // Observable states for UI binding
  final alerts = <ProactiveAlert>[].obs;
  final forecast = Rxn<CashFlowForecast>();
  final budgets = <String, SmartBudget>{}.obs;
  final isLoading = false.obs;

  // Boxes
  late Box<LocalTransaction> _transactionsBox;
  late Box<Job> _jobsBox;
  late Box<SavingsGoal> _savingsBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeBoxes();
    try {
      _engine = Get.find<KoalaMLEngine>();
    } catch (e) {
      // Should be initialized in main
      print('KoalaMLEngine not found in IntelligenceService: $e');
    }
    // Don't await refresh() to avoid blocking app startup
    // Run it in the background after a slight delay
    Future.delayed(const Duration(seconds: 1), () => refresh());
  }

  Future<void> _initializeBoxes() async {
    _transactionsBox = Hive.box<LocalTransaction>('transactionBox');
    _jobsBox = Hive.box<Job>('jobBox');
    _savingsBox = Hive.box<SavingsGoal>('savingsGoalBox');
  }

  /// Refresh all intelligent analyses
  Future<void> refresh() async {
    if (_engine == null) return;
    
    isLoading.value = true;
    try {
      final transactions = _transactionsBox.values.toList();
      final goals = _savingsBox.values.toList();
      
      // Run full ML analysis
      await _engine!.runFullAnalysis(transactions, goals);

      // Map ML results to IntelligenceService state
      _updateStateFromEngine();
    } finally {
      isLoading.value = false;
    }
  }

  /// Invalidate cache and force refresh
  Future<void> forceRefresh() async {
    await refresh();
  }

  void _updateStateFromEngine() {
    if (_engine == null) return;

    // 1. Alerts (Map MLInsights to ProactiveAlerts)
    final insights = _engine!.getInsights();
    alerts.value = insights.map((insight) => ProactiveAlert(
      id: insight.id,
      title: insight.title,
      message: insight.description,
      severity: _mapSeverity(insight.type),
      timestamp: DateTime.now(),
      actionSuggestion: insight.actionLabel ?? '',
      icon: _mapIcon(insight.type),
    )).toList();

    // 2. Forecast
    final engForecast = _engine!.currentForecast;
    if (engForecast != null) {
      forecast.value = CashFlowForecast(
        summary: ForecastSummary(
          endBalance: engForecast.forecasts.isNotEmpty ? engForecast.forecasts.last.predictedBalance : 0,
          lowestBalance: engForecast.lowestBalance,
          riskLevel: _mapRiskLevel(engForecast.riskLevel),
        ),
        dailyBalances: engForecast.forecasts.map((f) => f.predictedBalance).toList(),
      );
    }
    
    // 3. Budgets (GoalOptimizer)
    // Not fully implemented yet.
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SMART CATEGORIZATION
  // ══════════════════════════════════════════════════════════════════════════

  CategorySuggestion suggestCategory(String description, TransactionType type) {
    if (_engine == null) return CategorySuggestion(categoryId: null, confidence: 0);

    final prediction = _engine!.predictCategory(description, type);
    // Map prediction to suggestion
    // We need category ID, but prediction gives name.
    // Ideally CategoryClassifier should work with IDs.
    // For now, we return name-based suggestion if ID logic is handled elsewhere or lookup here.
    
    return CategorySuggestion(
      categoryId: null, // UI typically looks up by name or ID
      categoryName: prediction.categoryName,
      confidence: prediction.confidence,
    );
  }

  void learnFromCategoryChoice(String description, dynamic category, String? categoryId, TransactionType type) {
    // Engine handles learning via transaction updates usually
    // We can call a specific method if exposed
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CASH FLOW FORECASTING
  // ══════════════════════════════════════════════════════════════════════════

  CashFlowForecast getCashFlowForecast({int days = 30}) {
    // Return dummy or last cached
    return forecast.value ?? CashFlowForecast(
      summary: ForecastSummary(
        endBalance: 0,
        lowestBalance: 0,
        riskLevel: RiskLevel.unknown,
      ),
      dailyBalances: [],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTELLIGENCE SUMMARY
  // ══════════════════════════════════════════════════════════════════════════

  IntelligenceSummary getSummary() {
    final f = forecast.value;
    final alertsList = alerts.toList();
    
    // Calculate health score based on Engine's HealthScorer
    int score = 50;
    if (_engine != null && _engine!.currentHealth != null) {
      score = _engine!.currentHealth!.totalScore;
    }

    return IntelligenceSummary(
      riskLevel: f?.summary.riskLevel ?? RiskLevel.unknown,
      criticalAlertsCount: alertsList.where((a) => a.severity == AlertSeverity.critical).length,
      warningAlertsCount: alertsList.where((a) => a.severity == AlertSeverity.high).length,
      positiveAlertsCount: alertsList.where((a) => a.severity == AlertSeverity.positive).length,
      predictedEndBalance: f?.summary.endBalance ?? 0,
      lowestPredictedBalance: f?.summary.lowestBalance ?? 0,
      savingsRate: 0, // Need to expose from profile
      topAlert: alertsList.isNotEmpty ? alertsList.first : null,
      healthScore: score,
    );
  }
  
  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  
  AlertSeverity _mapSeverity(dynamic type) {
    // dynamic because imported enum from insight_generator might differ
    if (type.toString().contains('positive')) return AlertSeverity.positive;
    if (type.toString().contains('warning')) return AlertSeverity.high;
    if (type.toString().contains('tip')) return AlertSeverity.medium;
    return AlertSeverity.info;
  }
  
  dynamic _mapIcon(dynamic type) {
    // Return icon data? Or string?
    // ProactiveAlert expects IconData? 
    // I need to check ProactiveAlert definition.
    // It seems ProactiveAlert expects IconData.
    // But I can't import Flutter Material here easily if this is a pure Dart service?
    // GetXService can import Flutter.
    return null; // Placeholder, UI handles null
  }
  
  RiskLevel _mapRiskLevel(dynamic level) {
    // Map ForecastRiskLevel to RiskLevel
    if (level.toString().contains('high')) return RiskLevel.high;
    if (level.toString().contains('medium')) return RiskLevel.medium;
    return RiskLevel.low;
  }
  
  // Existing getters...
  List<ProactiveAlert> get highPriorityAlerts => alerts;
}

// ══════════════════════════════════════════════════════════════════════════
// DATA MODELS (Retained/Adapted)
// ══════════════════════════════════════════════════════════════════════════

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