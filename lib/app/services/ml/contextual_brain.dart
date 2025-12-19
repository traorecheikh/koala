import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:logger/logger.dart';

/// The "Contextual Brain" - Smart Autocomplete specific intelligence
/// Learns patterns like "Monday at 8am = Transport (500F)"
class ContextualBrain extends GetxService {
  final _logger = Logger();
  late FinancialContextService _context;

  // Knowledge Base
  // Key: "DayOfWeek(1-7)_Hour(0-23)"
  // Value: Map of CategoryID -> Frequency
  Map<String, Map<String, int>> _temporalMap = {};

  // Price Knowledge Base
  // Key: "CategoryID"
  // Value: List of historical amounts (to calculate median/mode)
  Map<String, List<double>> _categoryPriceHistory = {};

  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _context = Get.find<FinancialContextService>();

    // Debounce training to avoid spamming
    debounce(_context.allTransactions, (_) => _train(),
        time: const Duration(seconds: 3));
  }

  /// Trigger a full retraining on ALL available history
  /// This is critical for "Retroactive Smartness"
  Future<void> refresh() async {
    await _train();
  }

  // Minimum transactions required for reliable predictions
  static const int _minTransactions = 20;
  // Minimum data points per time slot for confident predictions
  static const int _minDataPointsPerSlot = 3;

  Future<void> _train() async {
    if (_context.allTransactions.isEmpty) return;

    try {
      final transactions = _context.allTransactions
          .where((t) => !t.isHidden && t.type == TransactionType.expense)
          .toList();

      // Require minimum transactions for reliable learning
      if (transactions.length < _minTransactions) {
        _logger.i(
            '🧠 [CONTEXT-BRAIN] Skipping training: only ${transactions.length} txs (need $_minTransactions)');
        isReady.value = false;
        return;
      }

      // Prepare data for heavy lifting
      // We can run this in an isolate or just async if data isn't huge
      // For thousands of tx, assume Isolate is safer, but simpler async for now to ensure robustness

      final tempTemporalMap = <String, Map<String, int>>{};
      final tempPriceHistory = <String, List<double>>{};

      for (final tx in transactions) {
        if (tx.categoryId == null) continue;

        // 1. Learn Context (When -> What)
        final key = _makeKey(tx.date);

        if (!tempTemporalMap.containsKey(key)) {
          tempTemporalMap[key] = {};
        }
        final catMap = tempTemporalMap[key]!;
        catMap[tx.categoryId!] = (catMap[tx.categoryId!] ?? 0) + 1;

        // 2. Learn Price (What -> How much)
        // We track price globally per category, but could refine to per-time if needed
        if (!tempPriceHistory.containsKey(tx.categoryId!)) {
          tempPriceHistory[tx.categoryId!] = [];
        }
        tempPriceHistory[tx.categoryId!]!.add(tx.amount);
      }

      // Atomic swap
      _temporalMap = tempTemporalMap;
      _categoryPriceHistory = tempPriceHistory;
      isReady.value = true;

      _logger.i(
          '🧠 [CONTEXT-BRAIN] Trained on ${transactions.length} txs. Learned ${_temporalMap.length} time slots.');
    } catch (e) {
      _logger.e('❌ [CONTEXT-BRAIN] Training Error', error: e);
    }
  }

  /// Predicts the most likely category and amount for a given time
  ContextualPrediction? predict(DateTime timestamp) {
    if (!isReady.value) return null;

    final key = _makeKey(timestamp);

    // Fuzzy matching: Check exact hour, then +/- 1 hour
    final hours = [0, -1, 1];
    final candidates = <String, double>{}; // Category -> Score

    for (var offset in hours) {
      final searchTime = timestamp.add(Duration(hours: offset));
      final searchKey = _makeKey(searchTime);
      final weight = offset == 0 ? 1.0 : 0.5; // Decay for neighbors

      final knowledge = _temporalMap[searchKey];
      if (knowledge != null) {
        knowledge.forEach((cat, freq) {
          candidates[cat] = (candidates[cat] ?? 0) + (freq * weight);
        });
      }
    }

    if (candidates.isEmpty) return null;

    // Find Winner
    var bestCategory = "";
    var bestScore = -1.0;

    candidates.forEach((cat, score) {
      if (score > bestScore) {
        bestScore = score;
        bestCategory = cat;
      }
    });

    // Require minimum data points for confident prediction
    if (bestScore < _minDataPointsPerSlot) {
      return null; // Not enough data for this time slot
    }

    // Contextual Price Prediction
    // Return Median of history for this category
    final predictedAmount = _getSmartPrice(bestCategory);

    // Calculate confidence (simple ratio)
    final totalScore = candidates.values.fold(0.0, (a, b) => a + b);
    final confidence = bestScore / totalScore;

    // Determine data quality based on how much evidence we have
    final dataQuality =
        bestScore >= 10 ? 'high' : (bestScore >= 5 ? 'medium' : 'low');

    return ContextualPrediction(
      categoryId: bestCategory,
      amount: predictedAmount,
      confidence: confidence,
      reason: _getReason(timestamp),
      dataQuality: dataQuality,
    );
  }

  double _getSmartPrice(String categoryId) {
    final history = _categoryPriceHistory[categoryId];
    if (history == null || history.isEmpty) return 0.0;

    history.sort();
    final middle = history.length ~/ 2;
    // Return Median to avoid massive outliers skewing the "smart" suggestion
    if (history.length % 2 == 1) {
      return history[middle];
    } else {
      return (history[middle - 1] + history[middle]) / 2.0;
    }
  }

  String _makeKey(DateTime d) {
    // Key: "Weekday-Hour" e.g. "1-14" for Mon 2pm
    return '${d.weekday}-${d.hour}';
  }

  String _getReason(DateTime date) {
    return 'Habitude détectée vers ${date.hour}h';
  }
}

class ContextualPrediction {
  final String categoryId;
  final double amount;
  final double confidence;
  final String reason;
  final String dataQuality; // 'high', 'medium', 'low'

  ContextualPrediction({
    required this.categoryId,
    required this.amount,
    required this.confidence,
    required this.reason,
    required this.dataQuality,
  });
}
