import 'dart:math';

import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/services/ml/feature_extractor.dart';

class AnomalyDetector {
  final FeatureExtractor _featureExtractor;

  AnomalyDetector(this._featureExtractor);

  List<SpendingAnomaly> detectAnomalies(
    List<LocalTransaction> recentTransactions,
    List<LocalTransaction> history,
    UserFinancialProfile? userProfile,
  ) {
    final anomalies = <SpendingAnomaly>[];

    // Group history by category
    final categoryStats = <String, _CategoryStats>{};
    for (final tx in history) {
      if (tx.type == TransactionType.expense && tx.category != null) {
        final cat = tx.category!.displayName;
        categoryStats.putIfAbsent(cat, () => _CategoryStats());
        categoryStats[cat]!.add(tx.amount);
      }
    }

    // Check recent transactions
    for (final tx in recentTransactions) {
      if (tx.type != TransactionType.expense) continue;
      
      final category = tx.category?.displayName ?? 'Autre';
      final stats = categoryStats[category];

      if (stats != null && stats.count > 5) {
        // Z-score detection
        final zScore = (tx.amount - stats.mean) / stats.stdDev;
        
        if (zScore > 3.0) {
          // High anomaly
          anomalies.add(SpendingAnomaly(
            transaction: tx,
            severity: AnomalySeverity.high,
            reason: 'Montant inhabituellement élevé pour $category (Z-score: ${zScore.toStringAsFixed(1)})',
            score: zScore,
          ));
        } else if (zScore > 2.0) {
          // Medium anomaly
          anomalies.add(SpendingAnomaly(
            transaction: tx,
            severity: AnomalySeverity.medium,
            reason: 'Montant supérieur à la moyenne pour $category',
            score: zScore,
          ));
        }
      }
      
      // Global threshold anomaly (e.g., > 50% of monthly income?)
      // Needs income data, which we assume might be in profile or derived
    }

    return anomalies;
  }
}

class _CategoryStats {
  double sum = 0;
  double sumSq = 0;
  int count = 0;

  void add(double value) {
    sum += value;
    sumSq += value * value;
    count++;
  }

  double get mean => count == 0 ? 0 : sum / count;
  double get stdDev {
    if (count < 2) return 1.0;
    final variance = (sumSq / count) - (mean * mean);
    // Prevent division by zero or extreme sensitivity for constant values
    // If variance is 0 (constant spending), return 1.0 to keep Z-score low for small diffs
    return max(sqrt(variance > 0 ? variance : 0), 1.0);
  }
}

class SpendingAnomaly {
  final LocalTransaction transaction;
  final AnomalySeverity severity;
  final String reason;
  final double score;

  SpendingAnomaly({
    required this.transaction,
    required this.severity,
    required this.reason,
    required this.score,
  });
  
  double get amount => transaction.amount;
  DateTime get date => transaction.date;
  String get categoryName => transaction.category?.displayName ?? 'Autre';
}

enum AnomalySeverity { low, medium, high }

