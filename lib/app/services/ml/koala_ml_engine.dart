import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/data/models/savings_goal.dart';
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

  // Cached state
  UserFinancialProfile? _currentUserProfile;
  List<SpendingAnomaly> _recentAnomalies = [];
  ForecastResult? _currentForecast;
  FinancialHealthScore? _currentHealth;

  Future<KoalaMLEngine> init() async {
    await modelStore.init();

    categoryClassifier = CategoryClassifier(featureExtractor, modelStore);
    anomalyDetector = AnomalyDetector(featureExtractor);
    behaviorProfiler = BehaviorProfiler();
    patternRecognizer = PatternRecognizer();
    timeSeriesEngine = TimeSeriesEngine(featureExtractor);
    healthScorer = FinancialHealthScorer();
    insightGenerator = InsightGenerator(behaviorProfiler);
    goalOptimizer = GoalOptimizer(timeSeriesEngine);
    simulatorEngine = SimulatorEngine(timeSeriesEngine);
    budgetSuggester = BudgetSuggester();

    _currentUserProfile = modelStore.getUserProfile();
    
    return this;
  }

  /// Run full analysis pipeline (e.g. on startup or background)
  Future<void> runFullAnalysis(List<LocalTransaction> allTransactions, List<SavingsGoal> goals) async {
    if (allTransactions.isEmpty) return;

    // 1. Train models if needed
    // In real app, this might be debounced or done in isolate
    await categoryClassifier.train(allTransactions);
    await timeSeriesEngine.train(allTransactions);

    // 2. Profile User
    final profile = behaviorProfiler.createProfile(allTransactions);
    await modelStore.saveUserProfile(profile);
    _currentUserProfile = profile;

    // 3. Detect Patterns
    final patterns = patternRecognizer.detectPatterns(allTransactions);
    for (final p in patterns) {
      await modelStore.savePattern(p);
    }

    // 4. Calculate Health
    _currentHealth = healthScorer.calculateScore(
      transactions: allTransactions,
      profile: profile,
      goals: goals,
    );

    // 5. Forecast
    // Assume current balance is sum of all (simplified)
    double currentBalance = 0; 
    for(var t in allTransactions) {
       if (t.type == TransactionType.income) currentBalance += t.amount;
       else currentBalance -= t.amount;
    }
    _currentForecast = timeSeriesEngine.predict(currentBalance, 30);
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