// ══════════════════════════════════════════════════════════════════════════
// DATA MODELS (Retained/Adapted)
// ══════════════════════════════════════════════════════════════════════════

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/ml/models/behavior_profiler.dart';
import 'package:koaa/app/services/ml/models/financial_health_scorer.dart';
import 'package:koaa/app/services/ml/smart_financial_brain.dart';
import 'package:koaa/app/services/intelligence/ai_learning_service.dart';
import 'package:hive_ce/hive.dart';

class ProactiveAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String actionSuggestion;
  final dynamic
      icon; // IconData is not easily serializable, store code or ignore? Store codePoint?
  // We will ignore icon for serialization and re-derive or use generic.
  bool isRead; // Mutable for read status

  ProactiveAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.actionSuggestion = '',
    this.icon,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'severity': severity.index,
        'timestamp': timestamp.toIso8601String(),
        'actionSuggestion': actionSuggestion,
        'isRead': isRead,
        // Icon not serialized
      };

  factory ProactiveAlert.fromJson(Map<String, dynamic> json) {
    return ProactiveAlert(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      severity: AlertSeverity.values[json['severity'] ?? 0],
      timestamp: DateTime.parse(json['timestamp']),
      actionSuggestion: json['actionSuggestion'] ?? '',
      isRead: json['isRead'] ?? false,
      icon: CupertinoIcons.exclamationmark_circle, // Default icon
    );
  }
}

enum AlertSeverity { critical, high, medium, low, positive, info }

// Duplicate IntelligenceService removed.

class CategorySuggestion {
  final String? categoryId;
  final String? categoryName;
  final double confidence;

  CategorySuggestion(
      {this.categoryId, this.categoryName, required this.confidence});
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
    if (healthScore >= 60) {
      return 'Vos finances vont bien, quelques points d\'attention.';
    }
    if (healthScore >= 40) {
      return 'Surveillez vos dépenses, des ajustements sont nécessaires.';
    }
    return 'Situation critique, action immédiate recommandée.';
  }
}

class IntelligenceService extends GetxService {
  final isLoading = false.obs;
  final forecast = Rxn<CashFlowForecast>();
  final RxList<ProactiveAlert> highPriorityAlerts = <ProactiveAlert>[].obs;

  Box? _insightsBox; // Hive Box

  // Reactive health score
  late Rx<IntelligenceSummary> _summary;

  late FinancialContextService _financialContextService;
  late SmartFinancialBrain
      _brain; // NEW: Use SmartFinancialBrain as source of truth
  late FinancialHealthScorer _healthScorer;
  late BehaviorProfiler _profiler;

  final List<Worker> _workers = [];
  bool _isCalculating = false;

  @override
  Future<void> onInit() async {
    super.onInit();

    // Open/Get the box
    if (Hive.isBoxOpen('insightsBox')) {
      _insightsBox = Hive.box('insightsBox');
    }

    // Load persisted alerts
    _loadPersistedAlerts();

    // Initialize summary with default values
    _summary = IntelligenceSummary(
      riskLevel: RiskLevel.unknown,
      criticalAlertsCount: 0,
      warningAlertsCount: 0,
      positiveAlertsCount: 0,
      predictedEndBalance: 0.0,
      lowestPredictedBalance: 0.0,
      savingsRate: 0.0,
      topAlert: null,
      healthScore: 50,
    ).obs;

    _financialContextService = Get.find<FinancialContextService>();
    _brain = Get.find<SmartFinancialBrain>(); // NEW: Get brain instance
    _healthScorer = FinancialHealthScorer();
    _profiler = BehaviorProfiler();

    // REFACTORED: Listen to SmartFinancialBrain's intelligence output
    // instead of duplicating listeners on FinancialContextService.
    // We don't need to manually call _calculateHealthScore() here because
    // the listener below will likely fire immediately with the current behavior subject value,
    // or very soon after when the brain finishes its initial analysis.
    _workers.add(ever(_brain.intelligence, (_) => _scheduleRecalculation()));
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  void _loadPersistedAlerts() {
    if (_insightsBox == null) return;

    final List<dynamic>? rawAlerts = _insightsBox!.get('alerts');
    if (rawAlerts != null) {
      highPriorityAlerts.assignAll(rawAlerts
          .map((e) => ProactiveAlert.fromJson(Map<String, dynamic>.from(e)))
          .toList());
    }
  }

  void _saveAlerts() {
    if (_insightsBox == null) return;
    final data = highPriorityAlerts.map((a) => a.toJson()).toList();
    _insightsBox!.put('alerts', data);
  }

  void markAsRead(String id) {
    final alert = highPriorityAlerts.firstWhereOrNull((a) => a.id == id);
    if (alert != null) {
      alert.isRead = true;
      highPriorityAlerts.refresh();
      _saveAlerts();
    }
  }

  // Debounce recalculations to avoid excessive CPU usage
  DateTime? _lastCalculation;
  void _scheduleRecalculation() {
    final now = DateTime.now();
    if (_lastCalculation != null &&
        now.difference(_lastCalculation!).inMilliseconds < 500) {
      return; // Don't recalculate more than twice per second
    }
    _lastCalculation = now;
    _calculateHealthScore();
  }

  Future<void> _calculateHealthScore() async {
    if (_isCalculating) return;
    _isCalculating = true;

    try {
      isLoading.value = true;

      // Get intelligence data from SmartFinancialBrain (single source of truth for spending)
      final brainIntelligence = _brain.intelligence.value;
      final spendingBehavior = brainIntelligence.spendingBehavior;
      final brainCashFlow = brainIntelligence.cashFlowPrediction;

      // Create a user profile from transactions
      final transactions = _financialContextService.allTransactions.toList();
      final profile = transactions.isNotEmpty
          ? _profiler.createProfile(transactions)
          : UserFinancialProfile(
              personaType: 'balanced',
              savingsRate: 0.0,
              consistencyScore: 0.5,
              categoryPreferences: {},
              detectedPatterns: [],
            );

      // Calculate the actual health score
      final healthScore = _healthScorer.calculateScore(
        context: _financialContextService,
        profile: profile,
      );

      // Use savings rate calculation
      final income = _financialContextService.totalMonthlyIncome.value;
      final expenses = _financialContextService.totalMonthlyExpenses.value;
      final savingsRate =
          income > 0 ? ((income - expenses) / income) * 100 : 0.0;

      // Determine risk level from health score (keep using local RiskLevel)
      RiskLevel riskLevel;
      if (healthScore.totalScore >= 80) {
        riskLevel = RiskLevel.low;
      } else if (healthScore.totalScore >= 60) {
        riskLevel = RiskLevel.medium;
      } else if (healthScore.totalScore >= 40) {
        riskLevel = RiskLevel.high;
      } else {
        riskLevel = RiskLevel.critical;
      }

      // Count penalty types
      final criticalCount =
          healthScore.penalties.where((p) => p.points >= 15).length;
      final warningCount = healthScore.penalties
          .where((p) => p.points >= 5 && p.points < 15)
          .length;

      // Create alerts from penalties
      _generateAlertsFromPenalties(healthScore.penalties);

      // Use brain's spending data for predictions
      final avgDailySpending = spendingBehavior.avgDailySpending;
      final predictedEndBalance = brainCashFlow.predictedMonthEndBalance;

      // Generate cash flow forecast using brain's data
      forecast.value = CashFlowForecast(
        summary: ForecastSummary(
          endBalance: predictedEndBalance,
          lowestBalance: predictedEndBalance - (avgDailySpending * 7),
          riskLevel: riskLevel,
        ),
        dailyBalances: [], // Not used by widget currently
      );

      // Update the summary with consistent data from brain
      _summary.value = IntelligenceSummary(
        riskLevel: riskLevel,
        criticalAlertsCount: criticalCount,
        warningAlertsCount: warningCount,
        positiveAlertsCount: healthScore.totalScore >= 80 ? 1 : 0,
        predictedEndBalance: predictedEndBalance,
        lowestPredictedBalance: predictedEndBalance - (avgDailySpending * 7),
        savingsRate: savingsRate,
        topAlert:
            highPriorityAlerts.isNotEmpty ? highPriorityAlerts.first : null,
        healthScore: healthScore.totalScore,
      );
    } catch (e) {
      // On error, keep previous score
      print('Error calculating health score: $e');
    } finally {
      isLoading.value = false;
      _isCalculating = false;
    }
  }

  void _generateAlertsFromPenalties(List<HealthPenalty> penalties) {
    final learningService = Get.find<AILearningService>();

    // Temporary list of new alerts
    List<ProactiveAlert> newAlerts = [];

    for (var penalty in penalties) {
      final alertType = _getPenaltyTitle(penalty.reason);

      if (!learningService.shouldShowAlert(alertType)) continue;

      AlertSeverity severity;
      IconData icon;

      if (penalty.points >= 15) {
        severity = AlertSeverity.critical;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
      } else if (penalty.points >= 10) {
        severity = AlertSeverity.high;
        icon = CupertinoIcons.exclamationmark_circle_fill;
      } else {
        severity = AlertSeverity.medium;
        icon = CupertinoIcons.info_circle_fill;
      }

      final id = 'penalty_${penalty.reason.hashCode}';

      // Check if exists
      final existing = highPriorityAlerts.firstWhereOrNull((a) => a.id == id);

      newAlerts.add(ProactiveAlert(
        id: id,
        title: alertType,
        message: penalty.reason,
        severity: severity,
        timestamp: existing?.timestamp ?? DateTime.now(),
        actionSuggestion: _getPenaltyAction(penalty.reason),
        icon: icon,
        isRead: existing?.isRead ?? false, // Preserve read status
      ));
    }

    highPriorityAlerts.assignAll(newAlerts);
    _saveAlerts(); // SAVE TO HIVE
  }

  String _getPenaltyTitle(String reason) {
    if (reason.contains('impulsive')) return 'Dépenses impulsives';
    if (reason.contains('10 jours')) return 'Dépenses trop rapides';
    if (reason.contains('Endettement')) return 'Endettement élevé';
    if (reason.contains('Prêts')) return 'Risque de prêts';
    if (reason.contains('revenu')) return 'Problème de revenus';
    return 'Alerte financière';
  }

  String _getPenaltyAction(String reason) {
    if (reason.contains('impulsive')) return 'Définir un budget strict';
    if (reason.contains('10 jours')) return 'Planifier vos dépenses';
    if (reason.contains('Endettement')) return 'Plan de remboursement';
    if (reason.contains('Prêts')) return 'Suivre vos prêts';
    return 'Voir les détails';
  }

  IntelligenceSummary getSummary() => _summary.value;

  Future<void> forceRefresh() async {
    await _calculateHealthScore();
  }

  void dismissAlert(String id) {
    // Find the alert to get its type before removing
    final alert = highPriorityAlerts.firstWhereOrNull((a) => a.id == id);
    if (alert != null) {
      // Learn from this dismissal
      final learningService = Get.find<AILearningService>();
      learningService.learnDismissal(alert.title);

      // Remove locally
      highPriorityAlerts.remove(alert);
      _saveAlerts();
    }
  }
}
