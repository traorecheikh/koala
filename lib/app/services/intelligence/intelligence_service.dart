import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/services/intelligence/koala_brain.dart';

/// Service that provides intelligent features across the app
/// Singleton pattern - use Get.find<IntelligenceService>() to access
class IntelligenceService extends GetxService {
  KoalaBrain? _brain;

  // Observable states for UI binding
  final alerts = <ProactiveAlert>[].obs;
  final forecast = Rxn<CashFlowForecast>();
  final budgets = <String, SmartBudget>{}.obs;
  final isLoading = false.obs;

  // Boxes
  late Box<LocalTransaction> _transactionsBox;
  late Box<Job> _jobsBox;
  late Box<SavingsGoal> _savingsBox;
  late Box<RecurringTransaction> _recurringBox;
  late Box<CategoryPattern> _patternsBox;
  late Box<UserBehavior> _behaviorBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeBoxes();
    _initializeBrain();
    await refresh();
  }

  Future<void> _initializeBoxes() async {
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(CategoryPatternAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(UserBehaviorAdapter());
    }

    // Get existing boxes (already opened in main.dart)
    _transactionsBox = Hive.box<LocalTransaction>('transactionBox');
    _jobsBox = Hive.box<Job>('jobBox');
    _savingsBox = Hive.box<SavingsGoal>('savingsGoalBox');
    _recurringBox = Hive.box<RecurringTransaction>('recurringTransactionBox');

    // Open intelligence-specific boxes
    _patternsBox = await Hive.openBox<CategoryPattern>('categoryPatternBox');
    _behaviorBox = await Hive.openBox<UserBehavior>('userBehaviorBox');
  }

  void _initializeBrain() {
    if (_brain != null) return;
    _brain = KoalaBrain(
      transactionsBox: _transactionsBox,
      jobsBox: _jobsBox,
      savingsBox: _savingsBox,
      recurringBox: _recurringBox,
      patternsBox: _patternsBox,
      behaviorBox: _behaviorBox,
    );
  }

  /// Refresh all intelligent analyses
  Future<void> refresh() async {
    isLoading.value = true;
    try {
      // Generate alerts
      alerts.value = _brain!.generateAlerts();

      // Generate forecast
      forecast.value = _brain!.forecastCashFlow();

      // Generate smart budgets
      budgets.value = _brain!.generateSmartBudgets();
    } finally {
      isLoading.value = false;
    }
  }

  /// Invalidate cache and force refresh
  Future<void> forceRefresh() async {
    _brain!.invalidateCache();
    await refresh();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SMART CATEGORIZATION
  // ══════════════════════════════════════════════════════════════════════════

  /// Get a category suggestion for a transaction description
  CategorySuggestion suggestCategory(String description, TransactionType type) {
    return _brain!.suggestCategory(description, type);
  }

  /// Learn from user's category choice to improve future suggestions
  void learnFromCategoryChoice(
    String description,
    TransactionCategory category,
    String? categoryId,
    TransactionType type,
  ) {
    _brain!.learnCategoryChoice(description, category, categoryId, type);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CASH FLOW FORECASTING
  // ══════════════════════════════════════════════════════════════════════════

  /// Get cash flow forecast for the next N days
  CashFlowForecast getCashFlowForecast({int days = 30}) {
    return _brain!.forecastCashFlow(days: days);
  }

  /// Get summary risk level
  RiskLevel get riskLevel => forecast.value?.summary.riskLevel ?? RiskLevel.unknown;

  /// Get end-of-period predicted balance
  double get predictedEndBalance => forecast.value?.summary.endBalance ?? 0;

  /// Get lowest predicted balance and date
  (double balance, DateTime date)? get lowestBalancePoint {
    final f = forecast.value;
    if (f == null) return null;
    return (f.summary.lowestBalance, f.summary.lowestBalanceDate);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PROACTIVE ALERTS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get all current alerts
  List<ProactiveAlert> getAlerts() => _brain!.generateAlerts();

  /// Get critical alerts only
  List<ProactiveAlert> get criticalAlerts =>
      alerts.where((a) => a.severity == AlertSeverity.critical).toList();

  /// Get high priority alerts
  List<ProactiveAlert> get highPriorityAlerts =>
      alerts.where((a) =>
        a.severity == AlertSeverity.critical ||
        a.severity == AlertSeverity.high
      ).toList();

  /// Check if there are any critical issues
  bool get hasCriticalIssues => criticalAlerts.isNotEmpty;

  /// Get positive alerts (achievements)
  List<ProactiveAlert> get achievements =>
      alerts.where((a) => a.severity == AlertSeverity.positive).toList();

  // ══════════════════════════════════════════════════════════════════════════
  // SMART BUDGETS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get smart budget recommendations
  Map<String, SmartBudget> getSmartBudgets() => _brain!.generateSmartBudgets();

  /// Get budget for a specific category
  SmartBudget? getBudgetForCategory(String category) => budgets[category];

  /// Get total recommended budget
  double get totalRecommendedBudget =>
      budgets.values.fold(0.0, (sum, b) => sum + b.recommendedAmount);

  /// Get savings recommendation
  SmartBudget? get savingsRecommendation => budgets['Épargne'];

  // ══════════════════════════════════════════════════════════════════════════
  // GOAL FEASIBILITY
  // ══════════════════════════════════════════════════════════════════════════

  /// Analyze if a savings goal is feasible
  GoalFeasibility analyzeGoalFeasibility(double targetAmount, int months) {
    return _brain!.analyzeGoalFeasibility(targetAmount, months);
  }

  /// Quick check if a goal amount is realistic in given timeframe
  bool isGoalRealistic(double amount, int months) {
    final analysis = analyzeGoalFeasibility(amount, months);
    return analysis.feasibilityLevel != FeasibilityLevel.unrealistic;
  }

  /// Get recommended savings goal based on current behavior
  double getRecommendedSavingsGoal(int months) {
    final analysis = analyzeGoalFeasibility(1000000, months); // Test with 1M
    return analysis.currentMonthlySavings * months * 0.9; // 90% of projected
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTELLIGENCE SUMMARY
  // ══════════════════════════════════════════════════════════════════════════

  /// Get a quick intelligence summary for dashboard
  IntelligenceSummary getSummary() {
    final f = forecast.value;
    final alertsList = alerts.toList();
    
    // Check if we have enough data
    if (_transactionsBox.isEmpty) {
      return IntelligenceSummary(
        riskLevel: RiskLevel.unknown,
        criticalAlertsCount: 0,
        warningAlertsCount: 0,
        positiveAlertsCount: 0,
        predictedEndBalance: 0,
        lowestPredictedBalance: 0,
        savingsRate: 0,
        topAlert: null,
        healthScore: 0, // 0 indicates "Need Data" state
      );
    }

    return IntelligenceSummary(
      riskLevel: f?.summary.riskLevel ?? RiskLevel.unknown,
      criticalAlertsCount: alertsList.where((a) => a.severity == AlertSeverity.critical).length,
      warningAlertsCount: alertsList.where((a) => a.severity == AlertSeverity.high || a.severity == AlertSeverity.medium).length,
      positiveAlertsCount: alertsList.where((a) => a.severity == AlertSeverity.positive).length,
      predictedEndBalance: f?.summary.endBalance ?? 0,
      lowestPredictedBalance: f?.summary.lowestBalance ?? 0,
      savingsRate: savingsRecommendation?.percentOfIncome ?? 0,
      topAlert: alertsList.isNotEmpty ? alertsList.first : null,
      healthScore: _calculateHealthScore(f, alertsList),
    );
  }

  int _calculateHealthScore(CashFlowForecast? forecast, List<ProactiveAlert> alerts) {
    if (_transactionsBox.length < 5) return 50; // Neutral starting score
    
    int score = 100;

    // Risk level impact
    switch (forecast?.summary.riskLevel) {
      case RiskLevel.critical:
        score -= 40;
        break;
      case RiskLevel.high:
        score -= 25;
        break;
      case RiskLevel.medium:
        score -= 10;
        break;
      default:
        break;
    }

    // Alert impact
    for (final alert in alerts) {
      switch (alert.severity) {
        case AlertSeverity.critical:
          score -= 15;
          break;
        case AlertSeverity.high:
          score -= 8;
          break;
        case AlertSeverity.medium:
          score -= 3;
          break;
        case AlertSeverity.positive:
          score += 5;
          break;
        default:
          break;
      }
    }

    // Savings rate bonus
    final savings = savingsRecommendation;
    if (savings != null && savings.percentOfIncome > 20) {
      score += 10;
    } else if (savings != null && savings.percentOfIncome > 10) {
      score += 5;
    }

    return score.clamp(0, 100);
  }
}

/// Summary of all intelligence for quick dashboard display
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

  /// Get a color-coded status
  String get statusEmoji {
    if (healthScore >= 80) return '🟢';
    if (healthScore >= 60) return '🟡';
    if (healthScore >= 40) return '🟠';
    return '🔴';
  }

  /// Get status text
  String get statusText {
    if (healthScore >= 80) return 'Excellent';
    if (healthScore >= 60) return 'Bon';
    if (healthScore >= 40) return 'Attention';
    return 'Critique';
  }

  /// Get status description
  String get statusDescription {
    if (healthScore >= 80) {
      return 'Vos finances sont en excellente santé !';
    }
    if (healthScore >= 60) {
      return 'Vos finances vont bien, quelques points d\'attention.';
    }
    if (healthScore >= 40) {
      return 'Surveillez vos dépenses, des ajustements sont nécessaires.';
    }
    return 'Situation critique, action immédiate recommandée.';
  }
}
