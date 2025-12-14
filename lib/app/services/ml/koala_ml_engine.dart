import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
import 'package:koaa/app/services/financial_context_service.dart'; // New import
import 'package:koaa/app/services/ml/feature_extractor.dart';
import 'package:koaa/app/services/ml/model_store.dart';
import 'package:koaa/app/services/ml/models/anomaly_detector.dart';
import 'package:koaa/app/services/ml/models/behavior_profiler.dart';
import 'package:koaa/app/services/ml/models/category_classifier.dart';
import 'package:koaa/app/services/ml/models/financial_health_scorer.dart';
import 'package:koaa/app/services/ml/models/goal_optimizer.dart';
import 'package:koaa/app/services/ml/models/insight_generator.dart';
import 'package:koaa/app/services/ml/models/budget_suggester.dart';
import 'package:koaa/app/services/ml/models/pattern_recognizer.dart';
import 'package:koaa/app/services/ml/models/simulator_engine.dart';
import 'package:koaa/app/services/ml/models/time_series_engine.dart';
import 'package:hive_ce/hive.dart'; // Import Hive to access HiveAesCipher
import 'package:flutter/foundation.dart';
import 'background_ml_worker.dart';

class KoalaMLEngine extends GetxService {
  final FeatureExtractor featureExtractor = FeatureExtractor();
  final MLModelStore modelStore = MLModelStore();

  late final CategoryClassifier categoryClassifier;
  late final AnomalyDetector anomalyDetector;
  late final BehaviorProfiler behaviorProfiler;
  late final PatternRecognizer patternRecognizer;
  late final TimeSeriesEngine timeSeriesEngine;
  late final FinancialHealthScorer healthScorer;
  late final InsightGenerator insightGenerator;
  late final GoalOptimizer goalOptimizer;
  late final SimulatorEngine simulatorEngine;
  late final BudgetSuggester budgetSuggester;
  
  late final FinancialContextService _financialContextService; // Injected

  // Cached state
  UserFinancialProfile? _currentUserProfile;
  List<SpendingAnomaly> _recentAnomalies = [];
  ForecastResult? _currentForecast;
  FinancialHealthScore? _currentHealth;

  @override
  void onClose() {
    modelStore.close(); // Close the Hive boxes managed by MLModelStore
    super.onClose();
  }

  Future<KoalaMLEngine> init(HiveAesCipher? cipher) async {
    await modelStore.init(cipher); // Pass the cipher here
    
    // Inject FinancialContextService (assumed to be initialized before MLEngine)
    _financialContextService = Get.find<FinancialContextService>();

    categoryClassifier = CategoryClassifier(featureExtractor, modelStore);
    anomalyDetector = AnomalyDetector(featureExtractor);
    behaviorProfiler = BehaviorProfiler();
    patternRecognizer = PatternRecognizer();
    timeSeriesEngine = TimeSeriesEngine(featureExtractor);
    healthScorer = FinancialHealthScorer();
    insightGenerator = InsightGenerator(behaviorProfiler);
    goalOptimizer = GoalOptimizer(timeSeriesEngine);
    simulatorEngine = SimulatorEngine(timeSeriesEngine, _financialContextService);
    budgetSuggester = BudgetSuggester();

    _currentUserProfile = modelStore.getUserProfile();
    
    return this;
  }

  /// Run full analysis pipeline (e.g. on startup or background)
  Future<void> runFullAnalysis(List<LocalTransaction> allTransactions, List<SavingsGoal> goals) async {
    if (allTransactions.isEmpty) return;

    // Serialize transactions for background compute
    final serialized = allTransactions.map((t) => {
      'id': t.id,
      'amount': t.amount,
      'type': t.type.toString(),
      'date': t.date.toIso8601String(),
    }).toList();

    // Run lightweight analysis in background isolate to avoid UI jank
    try {
      final result = await compute<Map<String, dynamic>, Map<String, dynamic>>(
        analyzeTransactions,
        {
          'transactions': serialized,
          'currentBalance': _financialContextService.currentBalance.value,
        },
      );

      // Apply returned summary to internal state (on main isolate)
      _currentForecast = ForecastResult(result['predictedEndBalance'] as double);
      _currentHealth = FinancialHealthScore(score: result['healthScore'] as int);

      // Kick off heavier model training asynchronously on main isolate but non-blocking
      unawaited(Future(() async {
        try {
          await categoryClassifier.train(allTransactions);
          await timeSeriesEngine.train(allTransactions);

          final profile = behaviorProfiler.createProfile(allTransactions);
          await modelStore.saveUserProfile(profile);
          _currentUserProfile = profile;

          final patterns = patternRecognizer.detectPatterns(allTransactions);
          for (final p in patterns) {
            await modelStore.savePattern(p);
          }
        } catch (e) {
          // Log and continue; heavy work may fail silently
        }
      }()));
    } catch (e) {
      // Fallback to previous synchronous path if compute fails
      await categoryClassifier.train(allTransactions);
      await timeSeriesEngine.train(allTransactions);

      final profile = behaviorProfiler.createProfile(allTransactions);
      await modelStore.saveUserProfile(profile);
      _currentUserProfile = profile;

      final patterns = patternRecognizer.detectPatterns(allTransactions);
      for (final p in patterns) {
        await modelStore.savePattern(p);
      }

      _currentHealth = FinancialHealthScore(score: 100);
      double currentBalance = _financialContextService.currentBalance.value;
      _currentForecast = timeSeriesEngine.predict(currentBalance, 30);
    }
  }

  /// Process a new transaction (real-time)
  Future<void> onTransactionAdded(LocalTransaction transaction, List<LocalTransaction> history) async {
    // 1. Categorize if needed (handled by UI usually, but we can suggest)
    
    // 2. Check Anomaly
    final anomalies = anomalyDetector.detectAnomalies([transaction], history, _currentUserProfile);
    if (anomalies.isNotEmpty) {
      _recentAnomalies.addAll(anomalies);
      // Trigger notification?
    }

    // 3. Update patterns incrementally? (Skip for now, wait for full analysis)
    
    // 4. Update classifier
    categoryClassifier.learnFromTransaction(transaction);
  }

  /// Get simplified insights for UI
  List<MLInsight> getInsights() {
    if (_currentUserProfile == null || _currentHealth == null) return [];
    
    return insightGenerator.generateInsights(
      profile: _currentUserProfile!,
      patterns: modelStore.getAllPatterns(),
      anomalies: _recentAnomalies,
      forecast: _currentForecast,
      health: _currentHealth!,
      context: _financialContextService,
    );
  }

  CategoryPrediction predictCategory(String description, TransactionType type) {
    return categoryClassifier.predict(description, type);
  }

  // Getters for Service access
  FinancialHealthScore? get currentHealth => _currentHealth;
  ForecastResult? get currentForecast => _currentForecast;
  UserFinancialProfile? get currentUserProfile => _currentUserProfile;

  double suggestBudgetForCategory(String categoryId, List<LocalTransaction> history) {
    return budgetSuggester.suggestBudgetForCategory(categoryId, history);
  }
}