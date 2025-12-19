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
import 'package:logger/logger.dart';
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
  final List<SpendingAnomaly> _recentAnomalies = [];
  ForecastResult? _currentForecast;
  FinancialHealthScore? _currentHealth;

  @override
  void onClose() {
    modelStore.close(); // Close the Hive boxes managed by MLModelStore
    super.onClose();
  }

  Future<KoalaMLEngine> init(HiveAesCipher? cipher) async {
    try {
      await modelStore.init(cipher); // Pass the cipher here
    } catch (e) {
      _logger.e('MLModelStore.init FAILED: $e');
      rethrow;
    }

    // Inject FinancialContextService (assumed to be initialized before MLEngine)
    _financialContextService = Get.find<FinancialContextService>();

    categoryClassifier = CategoryClassifier(featureExtractor, modelStore);
    anomalyDetector = AnomalyDetector();
    behaviorProfiler = BehaviorProfiler();
    patternRecognizer = PatternRecognizer();
    timeSeriesEngine = TimeSeriesEngine();
    healthScorer = FinancialHealthScorer();
    insightGenerator = InsightGenerator(behaviorProfiler);
    goalOptimizer = GoalOptimizer();
    simulatorEngine = SimulatorEngine(_financialContextService);
    budgetSuggester = BudgetSuggester();

    _currentUserProfile = modelStore.getUserProfile();

    // DEFER RETROACTIVE TRAINING
    // Don't block startup. Wait for UI to settle.
    // The SplashController or Home will call this, or we just delay it here.
    // Better to let it be called explicitly or just self-start after delay.
    startStartupTraining();

    return this;
  }

  final _logger = Logger();

  void startStartupTraining() {
    print('🐨 [DEBUG] KoalaMLEngine: startStartupTraining called.');
    // Wait for Financial Context to be fully initialized with data
    if (_financialContextService.isInitialized.value) {
      print('🐨 [DEBUG] FinancialContext ALREADY initialized. Running logic.');
      _runStartupLogic();
    } else {
      print('🐨 [DEBUG] Waiting for FinancialContext initialization...');
      // Listen once for initialization
      late Worker worker;
      worker = ever(_financialContextService.isInitialized, (initialized) {
        if (initialized) {
          print(
              '🐨 [DEBUG] FinancialContext initialized (event). Running logic.');
          _runStartupLogic();
          worker.dispose();
        }
      });
    }
  }

  void _runStartupLogic() async {
    // Check if context is ready (it should be, if we waited for it)
    if (!_financialContextService.isInitialized.value) {
      _logger.w(
          'FinancialContext NOT initialized when ML startup ran. Retrying in 1s...');
      await Future.delayed(const Duration(seconds: 1));
      if (!_financialContextService.isInitialized.value) return;
    }
    // Small delay to ensure UI has painted at least once frame
    await Future.delayed(const Duration(milliseconds: 500));

    final allTx = _financialContextService.allTransactions.toList();
    if (allTx.isNotEmpty) {
      Stopwatch sw = Stopwatch()..start();
      _logger.i(
          '🚀 [ML-STARTUP] ${DateTime.now().toIso8601String()} | Starting initial training on ${allTx.length} transactions...');

      try {
        await timeSeriesEngine.train(allTx);
        await Future.delayed(Duration.zero);
        await categoryClassifier.train(allTx);
        await Future.delayed(Duration.zero);

        final profile = behaviorProfiler.createProfile(allTx);
        await modelStore.saveUserProfile(profile);
        _currentUserProfile = profile;

        _logger.i(
            '✅ [ML-STARTUP] Training COMPLETE in ${sw.elapsedMilliseconds}ms. Ready for predictions.');
      } catch (e) {
        _logger.e('❌ [ML-STARTUP] Training Error', error: e);
      }
    } else {
      _logger.w('ℹ️ [ML-STARTUP] No transactions found. ML models idle.');
    }
  }

  /// Trigger retraining of models with new data (real-time learning)
  Future<void> refreshModels(List<LocalTransaction> transactions) async {
    if (transactions.isEmpty) return;

    final startTime = DateTime.now();
    _logger.i(
        '🔄 [ML-REALTIME] Detected ${transactions.length} transactions. Refreshing models...');

    // Use a lightweight lock or flags if needed, but for now just await individually
    // to prevent overlapping heavy compute if users spam updates.
    // Since this is called from SmartFinancialBrain which is DEBOUNCED,
    // we should be relatively safe.

    try {
      // Retrain Classifier
      await categoryClassifier.train(transactions);

      // Retrain TimeSeries
      await timeSeriesEngine.train(transactions);

      // Update Profile
      final profile = behaviorProfiler.createProfile(transactions);
      await modelStore.saveUserProfile(profile);
      _currentUserProfile = profile;

      // Update Patterns
      final patterns = patternRecognizer.detectPatterns(transactions);
      for (final p in patterns) {
        await modelStore.savePattern(p);
      }

      // Update Current Forecast
      final currentBalance = _financialContextService.currentBalance.value;
      _currentForecast = timeSeriesEngine.predict(currentBalance, 30);

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      _logger.i('✅ [ML-REALTIME] Context updated in ${elapsed}ms.');
    } catch (e) {
      _logger.e('❌ [ML-REALTIME] Refresh Failed', error: e);
    }
  }

  /// Run full analysis pipeline (e.g. on startup or background)
  Future<void> runFullAnalysis(
      List<LocalTransaction> allTransactions, List<SavingsGoal> goals) async {
    if (allTransactions.isEmpty) return;

    // Ensure engines are fresh
    await timeSeriesEngine.train(allTransactions);

    // Serialize transactions for background compute
    final serialized = allTransactions
        .map((t) => {
              'id': t.id,
              'amount': t.amount,
              'type': t.type.toString(),
              'date': t.date.toIso8601String(),
            })
        .toList();

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
      // Use TimeSeriesEngine for the forecast instead of the background result if possible
      // But we'll take the background result for risk/health for now, and override forecast

      _currentHealth = FinancialHealthScore(
        totalScore: result['healthScore'] as int,
        factors: [],
        penalties: [],
        calculatedAt: DateTime.now(),
      );

      // Kick off heavier model training asynchronously on main isolate but non-blocking
      (() async {
        try {
          await categoryClassifier.train(allTransactions);
          // TimeSeries already trained above

          final profile = behaviorProfiler.createProfile(allTransactions);
          await modelStore.saveUserProfile(profile);
          _currentUserProfile = profile;

          final patterns = patternRecognizer.detectPatterns(allTransactions);
          for (final p in patterns) {
            await modelStore.savePattern(p);
          }

          // GENERATE SMART FORECAST
          final currentBalance = _financialContextService.currentBalance.value;
          _currentForecast = timeSeriesEngine.predict(currentBalance, 30);
        } catch (e) {
          // Log and continue; heavy work may fail silently
        }
      })();
    } catch (e) {
      // Fallback to synchronous path
      await categoryClassifier.train(allTransactions);
      await timeSeriesEngine.train(allTransactions); // Retrain fallback

      final profile = behaviorProfiler.createProfile(allTransactions);
      await modelStore.saveUserProfile(profile);
      _currentUserProfile = profile;

      final patterns = patternRecognizer.detectPatterns(allTransactions);
      for (final p in patterns) {
        await modelStore.savePattern(p);
      }

      _currentHealth = FinancialHealthScore(
          totalScore: 100,
          factors: [],
          penalties: [],
          calculatedAt: DateTime.now());
      double currentBalance = _financialContextService.currentBalance.value;
      _currentForecast = timeSeriesEngine.predict(currentBalance, 30);
    }
  }

  /// Process a new transaction (real-time)
  Future<void> onTransactionAdded(
      LocalTransaction transaction, List<LocalTransaction> history) async {
    // 1. Categorize if needed (handled by UI usually, but we can suggest)

    // 2. Check Anomaly
    final anomalies = anomalyDetector
        .detectAnomalies([transaction], history, _currentUserProfile);
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

  double suggestBudgetForCategory(
      String categoryId, List<LocalTransaction> history) {
    return budgetSuggester.suggestBudgetForCategory(categoryId, history);
  }
}
