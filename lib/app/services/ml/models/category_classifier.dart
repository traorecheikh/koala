import 'dart:math';

import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/ml_model_state.dart';
import 'package:koaa/app/services/ml/feature_extractor.dart';
import 'package:koaa/app/services/ml/model_store.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

/// ML-powered category classification for transactions
/// Uses SoftmaxRegressor for multi-class classification with fallback to keywords
class CategoryClassifier {
  final FeatureExtractor _featureExtractor;
  final MLModelStore _store;

  // ML model
  SoftmaxRegressor? _model;
  bool _modelTrained = false;

  // Category mappings
  final List<String> _categoryLabels = [];
  final Map<String, int> _categoryToIndex = {};

  // Learned patterns from user corrections
  final Map<String, Map<String, int>> _learnedPatterns = {};

  // West African merchant keywords (hardcoded baseline)
  static const Map<String, List<String>> _categoryKeywords = {
    // Income
    'Salaire': ['salaire', 'paie', 'salary', 'virement employeur'],
    'Freelance': ['freelance', 'mission', 'prestation', 'projet', 'consultant'],
    'Investissement': ['dividende', 'interet', 'placement', 'rendement'],
    'Business': ['vente', 'recette', 'chiffre', 'commerce'],
    'Cadeau Reçu': ['cadeau', 'don', 'gift'],
    'Bonus': ['bonus', 'prime', 'gratification'],
    'Remboursement': ['remboursement', 'refund', 'retour'],

    // Expenses
    'Restaurant': ['restaurant', 'resto', 'manger', 'dejeuner', 'diner', 'cafe', 'maquis', 'dibiterie', 'garba', 'allocodrome', 'grillades'],
    'Transport': ['taxi', 'uber', 'yango', 'bolt', 'essence', 'carburant', 'parking', 'sotrama', 'gbaka', 'woro', 'bus', 'metro', 'peage'],
    'Shopping': ['achat', 'magasin', 'boutique', 'marche', 'jumia', 'shopping'],
    'Divertissement': ['cinema', 'concert', 'sortie', 'bar', 'boite', 'fete', 'loisir', 'jeu'],
    'Factures': ['facture', 'orange', 'mtn', 'moov', 'airtel', 'internet', 'telephone', 'abonnement', 'canal'],
    'Santé': ['pharmacie', 'medicament', 'docteur', 'hopital', 'clinique', 'consultation', 'labo', 'analyse'],
    'Éducation': ['ecole', 'scolarite', 'formation', 'cours', 'livre', 'universite', 'inscription'],
    'Loyer': ['loyer', 'location', 'appartement', 'maison', 'bail'],
    'Courses': ['supermarche', 'carrefour', 'casino', 'auchan', 'prix import', 'epicerie', 'marche'],
    'Services': ['cie', 'sodeci', 'senelec', 'electricite', 'eau', 'gaz'],
    'Assurance': ['assurance', 'mutuelle', 'sanlam', 'nsia', 'allianz'],
    'Voyage': ['voyage', 'billet', 'avion', 'hotel', 'train', 'vacances'],
    'Vêtements': ['vetement', 'chaussure', 'sac', 'habit', 'mode', 'friperie'],
    'Fitness': ['gym', 'sport', 'fitness', 'salle', 'musculation'],
    'Beauté': ['coiffure', 'beaute', 'salon', 'manucure', 'maquillage', 'parfum'],
    'Cadeaux': ['cadeau', 'anniversaire', 'mariage', 'naissance'],
    'Charité': ['don', 'zakat', 'charite', 'aumone', 'eglise', 'mosquee'],
    'Abonnements': ['netflix', 'spotify', 'dstv', 'canal', 'youtube', 'prime'],
    'Entretien': ['reparation', 'entretien', 'mecanique', 'plombier', 'electricien'],
  };

  static const String _modelName = 'category_classifier_v1';

  CategoryClassifier(this._featureExtractor, this._store);

  /// Train the classifier on historical transactions
  Future<void> train(List<LocalTransaction> transactions) async {
    if (transactions.length < 20) {
      return; // Not enough data for ML training
    }

    // Build category labels from data
    _buildCategoryLabels(transactions);

    if (_categoryLabels.length < 2) {
      return; // Need at least 2 categories
    }

    // Extract features and labels
    final dataRows = <List<dynamic>>[];

    for (final tx in transactions) {
      if (tx.type != TransactionType.expense) continue;

      final categoryName = tx.category?.displayName ?? 'Autre Dépense';
      final categoryIndex = _categoryToIndex[categoryName];
      if (categoryIndex == null) continue;

      // Extract description-based features for classification
      final descFeatures = _extractClassificationFeatures(tx.description, tx.amount, tx.date);
      
      // Combine features and label
      final row = [...descFeatures, categoryIndex];
      dataRows.add(row);
    }

    if (dataRows.isEmpty) return;

    try {
      // Create DataFrame
      // Features are f0, f1, ..., fn
      // Target is 'target'
      final featureCount = dataRows.first.length - 1;
      final header = List.generate(featureCount, (i) => 'f$i')..add('target');
      
      final dataFrame = DataFrame(dataRows, headerExists: false, columnNames: header);

      // Train SoftmaxRegressor
      _model = SoftmaxRegressor(
        dataFrame,
        ['target'],
        iterationsLimit: 100,
        learningRateType: LearningRateType.constant,
        initialLearningRate: 0.01,
      );

      _modelTrained = true;

      // Save model state
      final state = MLModelState(
        modelName: _modelName,
        weights: _model!.coefficientsByClasses
            .expand((row) => row.toList())
            .toList(),
        trainedAt: DateTime.now(),
        trainingDataCount: dataRows.length,
        validationScore: 0.0,
      );
      await _store.saveModelState(state);
    } catch (e) {
      // ML training failed, will fall back to keyword matching
      _modelTrained = false;
      print('Training failed: $e');
    }
  }

  /// Predict category for a transaction description
  CategoryPrediction predict(String description, TransactionType type) {
    final normalizedDesc = description.toLowerCase().trim();

    // 1. First check learned patterns (highest priority - user corrections)
    final learnedMatch = _matchLearnedPatterns(normalizedDesc, type);
    if (learnedMatch != null && learnedMatch.confidence > 0.8) {
      return learnedMatch;
    }

    // 2. Use ML model if trained
    if (_modelTrained && _model != null && type == TransactionType.expense) {
      final mlPrediction = _predictWithML(normalizedDesc, 10000, DateTime.now());
      if (mlPrediction.confidence > 0.6) {
        return mlPrediction;
      }
    }

    // 3. Fall back to keyword matching
    final keywordMatch = _matchKeywords(normalizedDesc, type);
    if (keywordMatch != null) {
      return keywordMatch;
    }

    // 4. Default category
    return CategoryPrediction(
      categoryName: type == TransactionType.income ? 'Autre Revenu' : 'Autre Dépense',
      confidence: 0.1,
      source: PredictionSource.fallback,
    );
  }


  /// Learn from a user's explicit category choice
  void learnFromTransaction(LocalTransaction tx) {
    final categoryName = tx.category?.displayName ?? 'Autre';
    final keywords = _extractKeywords(tx.description);

    for (final keyword in keywords) {
      _learnedPatterns.putIfAbsent(keyword, () => {});
      _learnedPatterns[keyword]![categoryName] =
          (_learnedPatterns[keyword]![categoryName] ?? 0) + 1;
    }
  }

  /// Learn from a category correction (stronger signal)
  void learnFromCorrection(LocalTransaction tx) {
    // A correction is a stronger signal - give it more weight
    for (int i = 0; i < 3; i++) {
      learnFromTransaction(tx);
    }
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  void _buildCategoryLabels(List<LocalTransaction> transactions) {
    _categoryLabels.clear();
    _categoryToIndex.clear();

    final categorySet = <String>{};
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense && tx.category != null) {
        categorySet.add(tx.category!.displayName);
      }
    }

    _categoryLabels.addAll(categorySet.toList()..sort());
    for (int i = 0; i < _categoryLabels.length; i++) {
      _categoryToIndex[_categoryLabels[i]] = i;
    }
  }

  List<double> _extractClassificationFeatures(String description, double amount, DateTime date) {
    final normalized = description.toLowerCase().trim();
    final words = _extractKeywords(normalized);

    // Simple bag-of-words style features + amount + temporal
    final features = <double>[];

    // Word presence features for top keywords
    final allKeywords = _categoryKeywords.values.expand((k) => k).toSet();
    for (final keyword in allKeywords.take(50)) {
      features.add(words.any((w) => w.contains(keyword)) ? 1.0 : 0.0);
    }

    // Amount features
    features.add(log(amount + 1) / 15.0); // Log-normalized
    // Use FeatureExtractor for consistent amount bucket
    features.add(_featureExtractor.extractAmountFeatures(amount, 'unknown', {}, 10000)[1]); 

    // Temporal features
    features.add(date.weekday / 7.0);
    features.add(date.hour / 24.0);

    return features;
  }

  CategoryPrediction? _matchLearnedPatterns(String description, TransactionType type) {
    final keywords = _extractKeywords(description);
    final categoryCounts = <String, int>{};

    for (final keyword in keywords) {
      final patterns = _learnedPatterns[keyword];
      if (patterns != null) {
        for (final entry in patterns.entries) {
          categoryCounts[entry.key] = (categoryCounts[entry.key] ?? 0) + entry.value;
        }
      }
    }

    if (categoryCounts.isEmpty) return null;

    // Find best match
    final sorted = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = sorted.first;
    final total = categoryCounts.values.fold<int>(0, (a, b) => a + b);
    final confidence = best.value / total;

    return CategoryPrediction(
      categoryName: best.key,
      confidence: min(0.95, confidence),
      source: PredictionSource.learned,
    );
  }

  CategoryPrediction _predictWithML(String description, double amount, DateTime date) {
    final features = _extractClassificationFeatures(description, amount, date);
    // Create DataFrame for prediction
    // Header must match training header minus target
    final featureCount = features.length;
    final header = List.generate(featureCount, (i) => 'f$i');
    
    final featureDataFrame = DataFrame([features], headerExists: false, columnNames: header);

    try {
      final probabilitiesDataFrame = _model!.predictProbabilities(featureDataFrame);
      final probsRow = probabilitiesDataFrame.rows.first;
      final probs = probsRow.map((e) => e as double).toList();

      // Find highest probability class
      int bestIndex = 0;
      double bestProb = probs[0];
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > bestProb) {
          bestProb = probs[i];
          bestIndex = i;
        }
      }

      return CategoryPrediction(
        categoryName: _categoryLabels[bestIndex],
        confidence: bestProb,
        source: PredictionSource.ml,
        probabilities: Map.fromIterables(_categoryLabels, probs),
      );
    } catch (e) {
      return CategoryPrediction(
        categoryName: 'Autre Dépense',
        confidence: 0.1,
        source: PredictionSource.fallback,
      );
    }
  }

  CategoryPrediction? _matchKeywords(String description, TransactionType type) {
    final isIncome = type == TransactionType.income;

    // Filter keywords by type
    final relevantCategories = isIncome
        ? ['Salaire', 'Freelance', 'Investissement', 'Business', 'Cadeau Reçu', 'Bonus', 'Remboursement']
        : _categoryKeywords.keys.where((k) => !['Salaire', 'Freelance', 'Investissement', 'Business', 'Cadeau Reçu', 'Bonus', 'Remboursement'].contains(k));

    for (final category in relevantCategories) {
      final keywords = _categoryKeywords[category];
      if (keywords == null) continue;

      for (final keyword in keywords) {
        if (description.contains(keyword)) {
          return CategoryPrediction(
            categoryName: category,
            confidence: 0.75,
            source: PredictionSource.keyword,
          );
        }
      }
    }

    return null;
  }

  List<String> _extractKeywords(String text) {
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();
  }
}

/// Result of category prediction
class CategoryPrediction {
  final String categoryName;
  final double confidence;
  final PredictionSource source;
  final Map<String, double>? probabilities;

  CategoryPrediction({
    required this.categoryName,
    required this.confidence,
    required this.source,
    this.probabilities,
  });

  bool get isHighConfidence => confidence >= 0.7;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.7;
  bool get isLowConfidence => confidence < 0.5;
}

/// Source of the prediction
enum PredictionSource {
  ml,       // From trained ML model
  learned,  // From user corrections
  keyword,  // From keyword matching
  fallback, // Default when nothing matches
}

