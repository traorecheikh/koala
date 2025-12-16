import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/ml/contextual_brain_worker.dart';
import 'package:logger/logger.dart';

/// The "Contextual Brain" - Smart Autocomplete specific intelligence
/// Learns patterns like "Monday at 8am = Transport" or "Sunday at 14h = Restaurant"
class ContextualBrain extends GetxService {
  final _logger = Logger();
  late FinancialContextService _context;

  // Training Data: Maps features to outcomes
  // Key: "Day-HourBucket" (e.g., "1-8" for Mon 8am)
  // Value: Map of CategoryID -> Count
  Map<String, Map<String, int>> _timeCategoryMatrix = {};

  // Maps "Day-HourBucket-Category" -> List of Amounts (to find avg/median)
  Map<String, List<double>> _amountHistory = {};

  final isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _context = Get.find<FinancialContextService>();

    // Debounce training to avoid spamming isolates
    debounce(_context.allTransactions, (_) => _train(),
        time: const Duration(seconds: 2));

    // Initial training (Async to not block init)
    if (_context.allTransactions.isNotEmpty) {
      // Small delay to let app startup breathe
      Future.delayed(const Duration(milliseconds: 500), _train);
    }
  }

  Future<void> _train() async {
    if (_context.allTransactions.isEmpty) return;

    try {
      final transactions = _context.allTransactions
          .where((t) => !t.isHidden && t.type == TransactionType.expense)
          .toList();

      if (transactions.isEmpty) return;

      // Serialize for isolate
      final rawData = transactions
          .map((t) => {
                'categoryId': t.categoryId,
                'amount': t.amount,
                'type': t.type.name, // enum to string
                'date': t.date.toIso8601String(),
              })
          .toList();

      final payload = ContextualTrainPayload(rawData);

      // Compute in background isolate
      final result =
          await compute<ContextualTrainPayload, ContextualTrainResult>(
        trainContextualBrain,
        payload,
      );

      // Apply result
      _timeCategoryMatrix = result.matrix;
      _amountHistory = result.amountHistory;
      isReady.value = true;
      _logger.d(
          'ContextualBrain trained on ${transactions.length} transactions (Isolate).');
    } catch (e) {
      _logger.e('Error training ContextualBrain in isolate', error: e);
    }
  }

  /// Predicts the most likely category and amount for a given time
  /// Uses a "fuzzy" window (current hour +/- 1) to allow for flexibility
  ContextualPrediction? predict(DateTime timestamp) {
    if (!isReady.value) return null;

    final day = timestamp.weekday;
    final currentHour = timestamp.hour;

    // Hours to check: current, previous, next (handling wrap-around for 0/23)
    final hoursToCheck = [
      currentHour,
      (currentHour - 1) < 0 ? 23 : currentHour - 1,
      (currentHour + 1) > 23 ? 0 : currentHour + 1
    ];

    final Map<String, double> aggregatedScores = {};
    double totalWeight = 0;

    // Aggregate counts from neighbors with weights
    // Current hour = 1.0 weight
    // Adjacent hours = 0.5 weight
    for (final h in hoursToCheck) {
      final key = '$day-$h';
      final categoryCounts = _timeCategoryMatrix[key];
      final weight = (h == currentHour) ? 1.0 : 0.5;

      if (categoryCounts != null) {
        categoryCounts.forEach((cat, count) {
          aggregatedScores[cat] =
              (aggregatedScores[cat] ?? 0) + (count * weight);
          totalWeight += (count * weight);
        });
      }
    }

    if (aggregatedScores.isEmpty) return null;

    // Find top category
    String? topCategory;
    double maxScore = 0;

    aggregatedScores.forEach((cat, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = cat;
      }
    });

    if (topCategory == null) return null;

    // Calculate confidence
    final confidence = totalWeight > 0 ? maxScore / totalWeight : 0.0;

    // Threshold check (lower threshold slightly due to fuzzy matching spreading weights)
    if (maxScore < 1.5) return null;

    // Predict amount (median from the exact current hour if available, else primary training data)
    // We prioritize the current hour for amount accuracy
    String amountKey = '$day-$currentHour-$topCategory';
    List<double> amounts = _amountHistory[amountKey] ?? [];

    // Fallback to neighbors if current hour has no data for this category
    if (amounts.isEmpty) {
      for (final h in hoursToCheck) {
        if (h == currentHour) continue;
        final fallbackKey = '$day-$h-$topCategory';
        if (_amountHistory.containsKey(fallbackKey)) {
          amounts = _amountHistory[fallbackKey]!;
          amountKey = fallbackKey; // update for logging/debugging if needed
          break;
        }
      }
    }

    amounts.sort();
    double predictedAmount = 0;
    if (amounts.isNotEmpty) {
      predictedAmount = amounts[amounts.length ~/ 2];
    }

    return ContextualPrediction(
      categoryId: topCategory!,
      amount: predictedAmount,
      confidence: confidence,
      reason: _getReason(timestamp),
    );
  }

  String _getReason(DateTime date) {
    final hour = date.hour;
    // Format to look nice, e.g., "vers 14h"
    return 'Basé sur vos habitudes vers ${hour}h';
  }
}

class ContextualPrediction {
  final String categoryId;
  final double amount;
  final double confidence;
  final String reason;

  ContextualPrediction({
    required this.categoryId,
    required this.amount,
    required this.confidence,
    required this.reason,
  });
}
