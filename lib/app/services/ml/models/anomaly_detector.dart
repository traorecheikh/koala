import 'dart:math';

import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';

/// ML-enhanced Anomaly Detector
/// Uses multiple detection strategies:
/// 1. Z-score for amount-based anomalies
/// 2. Temporal pattern deviation (unusual times)
/// 3. Frequency burst detection (too many transactions)
/// 4. Multi-dimensional isolation scoring
class AnomalyDetector {
  AnomalyDetector();

  // Minimum history required for reliable anomaly detection
  static const int _minHistoryTransactions = 20;

  List<SpendingAnomaly> detectAnomalies(
    List<LocalTransaction> recentTransactions,
    List<LocalTransaction> history,
    UserFinancialProfile? userProfile,
  ) {
    final anomalies = <SpendingAnomaly>[];

    // Check minimum history - don't flag anomalies for new users
    if (history.length < _minHistoryTransactions) {
      // Not enough data to detect anomalies reliably
      return anomalies;
    }

    // Build statistical models from history
    final categoryStats = _buildCategoryStats(history);
    final temporalProfile = _buildTemporalProfile(history);
    final frequencyProfile = _buildFrequencyProfile(history);

    // Check recent transactions for anomalies
    for (final tx in recentTransactions) {
      if (tx.type != TransactionType.expense) continue;

      final category = tx.category.displayName;

      // 1. Amount-based anomaly (Z-score)
      final amountAnomaly = _detectAmountAnomaly(tx, category, categoryStats);
      if (amountAnomaly != null) {
        anomalies.add(amountAnomaly);
        continue; // Don't double-flag
      }

      // 2. Temporal anomaly (unusual time of day/week)
      final temporalAnomaly =
          _detectTemporalAnomaly(tx, category, temporalProfile);
      if (temporalAnomaly != null) {
        anomalies.add(temporalAnomaly);
        continue;
      }

      // 3. Frequency burst detection
      final burstAnomaly =
          _detectFrequencyBurst(tx, recentTransactions, frequencyProfile);
      if (burstAnomaly != null) {
        anomalies.add(burstAnomaly);
      }
    }

    // 4. Multi-dimensional isolation scoring for edge cases
    anomalies.addAll(
        _detectIsolationAnomalies(recentTransactions, history, categoryStats));

    return anomalies;
  }

  /// Build category-level statistics for amount analysis
  Map<String, _CategoryStats> _buildCategoryStats(
      List<LocalTransaction> history) {
    final stats = <String, _CategoryStats>{};
    for (final tx in history) {
      if (tx.type == TransactionType.expense) {
        final cat = tx.category.displayName;
        stats.putIfAbsent(cat, () => _CategoryStats());
        stats[cat]!.add(tx.amount);
      }
    }
    return stats;
  }

  /// Build temporal profile: when does user typically spend in each category?
  Map<String, _TemporalProfile> _buildTemporalProfile(
      List<LocalTransaction> history) {
    final profiles = <String, _TemporalProfile>{};
    for (final tx in history) {
      if (tx.type == TransactionType.expense) {
        final cat = tx.category.displayName;
        profiles.putIfAbsent(cat, () => _TemporalProfile());
        profiles[cat]!.add(tx.date);
      }
    }
    return profiles;
  }

  /// Build frequency profile: how many transactions per day/week typically?
  _FrequencyProfile _buildFrequencyProfile(List<LocalTransaction> history) {
    return _FrequencyProfile(history);
  }

  /// Detect amount-based anomalies using Z-score
  SpendingAnomaly? _detectAmountAnomaly(
    LocalTransaction tx,
    String category,
    Map<String, _CategoryStats> stats,
  ) {
    final categoryStats = stats[category];
    if (categoryStats == null || categoryStats.count < 5) return null;

    final zScore = (tx.amount - categoryStats.mean) / categoryStats.stdDev;

    if (zScore > 3.0) {
      return SpendingAnomaly(
        transaction: tx,
        severity: AnomalySeverity.high,
        reason:
            'Montant inhabituellement élevé pour $category (${(zScore * 100 / 3).round()}% au-dessus de la normale)',
        score: zScore,
        anomalyType: AnomalyType.amount,
      );
    } else if (zScore > 2.0) {
      return SpendingAnomaly(
        transaction: tx,
        severity: AnomalySeverity.medium,
        reason: 'Montant supérieur à la moyenne pour $category',
        score: zScore,
        anomalyType: AnomalyType.amount,
      );
    }

    return null;
  }

  /// Detect temporal anomalies: spending at unusual times
  SpendingAnomaly? _detectTemporalAnomaly(
    LocalTransaction tx,
    String category,
    Map<String, _TemporalProfile> profiles,
  ) {
    final profile = profiles[category];
    if (profile == null || profile.count < 10) return null;

    // Check if this transaction's time is unusual for this category
    final hourDeviation = profile.getHourDeviation(tx.date.hour);
    final dayDeviation = profile.getDayOfWeekDeviation(tx.date.weekday);

    // High deviation = unusual time
    final combinedDeviation = (hourDeviation + dayDeviation) / 2;

    if (combinedDeviation > 0.8) {
      return SpendingAnomaly(
        transaction: tx,
        severity: AnomalySeverity.low,
        reason:
            'Achat à un moment inhabituel (${_formatTimeOfDay(tx.date.hour)}, ${_formatDayOfWeek(tx.date.weekday)})',
        score: combinedDeviation,
        anomalyType: AnomalyType.temporal,
      );
    }

    return null;
  }

  /// Detect frequency bursts: too many transactions in short period
  SpendingAnomaly? _detectFrequencyBurst(
    LocalTransaction tx,
    List<LocalTransaction> recent,
    _FrequencyProfile frequencyProfile,
  ) {
    // Count transactions in the same day
    final sameDay = recent
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == tx.date.year &&
            t.date.month == tx.date.month &&
            t.date.day == tx.date.day)
        .length;

    final avgDaily = frequencyProfile.avgDailyTransactions;
    if (avgDaily < 1) return null;

    final burstRatio = sameDay / avgDaily;

    if (burstRatio > 3.0) {
      return SpendingAnomaly(
        transaction: tx,
        severity: AnomalySeverity.medium,
        reason:
            'Rafale de dépenses: $sameDay transactions ce jour vs ${avgDaily.toStringAsFixed(1)} en moyenne',
        score: burstRatio,
        anomalyType: AnomalyType.frequency,
      );
    }

    return null;
  }

  /// Multi-dimensional isolation scoring for complex anomalies
  /// Uses simplified Isolation Forest concept
  List<SpendingAnomaly> _detectIsolationAnomalies(
    List<LocalTransaction> recent,
    List<LocalTransaction> history,
    Map<String, _CategoryStats> stats,
  ) {
    final anomalies = <SpendingAnomaly>[];

    // For each recent transaction, calculate isolation score
    for (final tx in recent) {
      if (tx.type != TransactionType.expense) continue;

      final score = _calculateIsolationScore(tx, history, stats);

      if (score > 0.75) {
        anomalies.add(SpendingAnomaly(
          transaction: tx,
          severity: AnomalySeverity.high,
          reason:
              'Transaction très inhabituelle par rapport à votre historique',
          score: score,
          anomalyType: AnomalyType.isolation,
        ));
      }
    }

    return anomalies;
  }

  /// Calculate isolation score (0-1, higher = more anomalous)
  double _calculateIsolationScore(
    LocalTransaction tx,
    List<LocalTransaction> history,
    Map<String, _CategoryStats> stats,
  ) {
    // Simple multi-dimensional scoring
    double score = 0;
    int factors = 0;

    // Factor 1: Amount deviation
    final category = tx.category.displayName;
    final catStats = stats[category];
    if (catStats != null && catStats.count > 3) {
      final zScore = (tx.amount - catStats.mean) / catStats.stdDev;
      score += min(1.0, zScore / 4.0);
      factors++;
    }

    // Factor 2: Category rarity (new or rare category?)
    final categoryCount = history
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category.displayName == category)
        .length;
    final totalExpenses =
        history.where((t) => t.type == TransactionType.expense).length;
    if (totalExpenses > 10) {
      final categoryRatio = categoryCount / totalExpenses;
      score += max(0, 0.9 - categoryRatio * 10); // Rare category = higher score
      factors++;
    }

    // Factor 3: Description novelty (never seen before?)
    final descWords = tx.description.toLowerCase().split(' ');
    final allDescriptions =
        history.map((t) => t.description.toLowerCase()).join(' ');
    int novelWords = descWords
        .where((w) => w.length > 2 && !allDescriptions.contains(w))
        .length;
    if (descWords.isNotEmpty) {
      score += min(1.0, novelWords / descWords.length);
      factors++;
    }

    return factors > 0 ? score / factors : 0;
  }

  String _formatTimeOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'matin';
    if (hour >= 12 && hour < 17) return 'après-midi';
    if (hour >= 17 && hour < 21) return 'soir';
    return 'nuit';
  }

  String _formatDayOfWeek(int weekday) {
    const days = [
      '',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche'
    ];
    return days[weekday];
  }
}

/// Statistics for a category
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
    return max(sqrt(variance > 0 ? variance : 0), 1.0);
  }
}

/// Temporal spending profile for a category
class _TemporalProfile {
  final List<int> _hourCounts = List.filled(24, 0);
  final List<int> _dayCounts = List.filled(7, 0);
  int count = 0;

  void add(DateTime date) {
    _hourCounts[date.hour]++;
    _dayCounts[date.weekday - 1]++;
    count++;
  }

  /// Get deviation: 0 = typical, 1 = very unusual
  double getHourDeviation(int hour) {
    if (count < 10) return 0;
    final expected = count / 24;
    final actual = _hourCounts[hour];
    if (expected == 0) return 1.0;
    final ratio = actual / expected;
    // If ratio < 0.1, this hour is rarely used → deviation close to 1
    return max(0, min(1, 1 - ratio));
  }

  double getDayOfWeekDeviation(int weekday) {
    if (count < 10) return 0;
    final expected = count / 7;
    final actual = _dayCounts[weekday - 1];
    if (expected == 0) return 1.0;
    final ratio = actual / expected;
    return max(0, min(1, 1 - ratio));
  }
}

/// Frequency profile: transactions per day
class _FrequencyProfile {
  double avgDailyTransactions = 0;

  _FrequencyProfile(List<LocalTransaction> history) {
    if (history.isEmpty) return;

    final expenses =
        history.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return;

    expenses.sort((a, b) => a.date.compareTo(b.date));
    final days = expenses.last.date.difference(expenses.first.date).inDays + 1;
    avgDailyTransactions = expenses.length / max(1, days);
  }
}

/// Spending anomaly result
class SpendingAnomaly {
  final LocalTransaction transaction;
  final AnomalySeverity severity;
  final String reason;
  final double score;
  final AnomalyType anomalyType;

  SpendingAnomaly({
    required this.transaction,
    required this.severity,
    required this.reason,
    required this.score,
    this.anomalyType = AnomalyType.amount,
  });

  double get amount => transaction.amount;
  DateTime get date => transaction.date;
  String get categoryName => transaction.category.displayName;
}

enum AnomalySeverity { low, medium, high }

/// Type of anomaly detected
enum AnomalyType {
  amount, // Unusual amount
  temporal, // Unusual time
  frequency, // Burst of transactions
  isolation, // Multi-dimensional outlier
}
