import 'package:koaa/app/data/models/local_transaction.dart';

/// Advanced Time Series Engine using Triple Exponential Smoothing (Holt-Winters)
/// Handles Level (baseline), Trend (slope), and Seasonality (repeating patterns)
class TimeSeriesEngine {
  // Holt-Winters Components
  double _alpha = 0.4; // Level smoothing (sensible default)
  double _beta = 0.1; // Trend smoothing
  double _gamma = 0.3; // Seasonality smoothing

  final int _seasonLength =
      7; // Weekly seasonality is strongest in personal finance
  List<double>? _seasonalIndices;
  double? _level;
  double? _trend;

  bool _isTrained = false;

  TimeSeriesEngine();

  /// Train the model on historical transaction data
  /// OPTION A: Train only on EXPENSE data to avoid income spikes corrupting trend
  /// Income is handled separately via jobs/recurring transactions in SmartFinancialBrain
  Future<void> train(List<LocalTransaction> history) async {
    if (history.isEmpty) return;

    // Filter to expenses only AND exclude debt repayments
    // Income spikes and debt repayments corrupt the trend
    final expenses = history
        .where((tx) =>
            tx.type == TransactionType.expense &&
            (tx.linkedDebtId == null || tx.linkedDebtId!.isEmpty))
        .toList();

    if (expenses.isEmpty) {
      _isTrained = false;
      return;
    }

    // 1. Preprocessing: Aggregate to Daily Expense Flow (negative values)
    final dailyExpenseFlow = <DateTime, double>{};

    DateTime minDate = DateTime.now();
    DateTime maxDate = DateTime.fromMillisecondsSinceEpoch(0);

    for (final tx in expenses) {
      if (tx.date.isBefore(minDate)) minDate = tx.date;
      if (tx.date.isAfter(maxDate)) maxDate = tx.date;

      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      // Store as negative since these are expenses (outflows)
      dailyExpenseFlow[date] = (dailyExpenseFlow[date] ?? 0) - tx.amount;
    }

    // Fill in missing days with 0 (essential for time series)
    final sortedData = <double>[];
    final totalDays = maxDate.difference(minDate).inDays + 1;

    // Require minimum data: at least 14 days AND 20 transactions
    if (totalDays < _seasonLength * 2 || expenses.length < 20) {
      _trainSimpleAvg(dailyExpenseFlow);
      print(
          '🔮 [TIMESERIES] Using simple avg: ${totalDays}d, ${expenses.length} txs');
      return;
    }

    for (int i = 0; i < totalDays; i++) {
      final date = minDate.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      sortedData.add(dailyExpenseFlow[dateKey] ?? 0.0);
    }

    // 2. Holt-Winters Initialization (Additive)
    _seasonalIndices = List<double>.filled(_seasonLength, 0.0);
    double seasonalAvg = 0;
    for (int i = 0; i < _seasonLength; i++) {
      _seasonalIndices![i] = sortedData[i];
      seasonalAvg += sortedData[i];
    }
    seasonalAvg /= _seasonLength;

    // Normalize seasonality roughly around 0 for additive
    for (int i = 0; i < _seasonLength; i++) {
      _seasonalIndices![i] -= seasonalAvg;
    }

    // Initial Level and Trend
    _level = sortedData[0];
    _trend = 0.0;

    // 3. Iterative Smoothing (Training)
    for (int t = 0; t < sortedData.length; t++) {
      final val = sortedData[t];
      final lastLevel = _level!;
      final lastTrend = _trend!;
      final seasonIdx = t % _seasonLength;
      final lastSeason = _seasonalIndices![seasonIdx];

      final newLevel =
          _alpha * (val - lastSeason) + (1 - _alpha) * (lastLevel + lastTrend);
      final newTrend = _beta * (newLevel - lastLevel) + (1 - _beta) * lastTrend;
      final newSeason = _gamma * (val - lastLevel) + (1 - _gamma) * lastSeason;

      _level = newLevel;
      _trend = newTrend;
      _seasonalIndices![seasonIdx] = newSeason;
    }

    _isTrained = true;
    print(
        '🔮 [TIMESERIES] Trained on ${expenses.length} expenses over ${totalDays}d. Level=$_level, Trend=$_trend');
  }

  void _trainSimpleAvg(Map<DateTime, double> dailyFlow) {
    // Not enough data for HW, just compute average daily change
    if (dailyFlow.isEmpty) return;
    final sum = dailyFlow.values.reduce((a, b) => a + b);
    final avg = sum / dailyFlow.length;
    _level = avg; // Treat level as average daily change
    _trend = 0;
    _seasonalIndices = List.filled(_seasonLength, 0);
    _isTrained = true;
  }

  /// Predict future balances utilizing the trained components
  ForecastResult predict(double currentBalance, int days) {
    // Fallback if not trained
    if (!_isTrained || _level == null) {
      return _simpleFallbackForecast(currentBalance, days);
    }

    final predictions = <DailyForecast>[];
    final now = DateTime.now();
    double minBalance = currentBalance;
    int? daysUntilZero;

    // We project the *changes* cumulatively onto the current balance
    double runningBalance = currentBalance;

    // Finding the current seasonality index offset based on "today" relative to training start is complex
    // Simplified: Use day of week as the index proxy since we used 7-day seasonality
    final initialDow = now.weekday - 1; // 0=Mon, 6=Sun

    for (int h = 1; h <= days; h++) {
      final futureDate = now.add(Duration(days: h));

      // Forecast Change = Level + h*Trend + Seasonality
      final seasonIdx = (initialDow + h) % _seasonLength;
      final seasonalComponent = _seasonalIndices![seasonIdx];

      // Note: In HW, 'h' is steps ahead from *end of training*.
      // Ideally we retrain daily. If we assume training ended "yesterday", h starts at 1.
      final expectedDailyChange = _level! + (h * _trend!) + seasonalComponent;

      // Apply change
      runningBalance += expectedDailyChange;

      // Confidence Intervals ( widen as we go further )
      // Simple heuristic: standard deviation proxy grows with sqrt(h)
      final uncertainty = (runningBalance.abs() * 0.05) +
          (h * 50); // Base 5% + growing flat error

      if (runningBalance < minBalance) minBalance = runningBalance;
      if (runningBalance <= 0 && daysUntilZero == null) daysUntilZero = h;

      predictions.add(DailyForecast(
        date: futureDate,
        predictedBalance: runningBalance,
        lowerBound: runningBalance - uncertainty,
        upperBound: runningBalance + uncertainty,
      ));
    }

    // Determine risk
    ForecastRiskLevel risk;
    if (daysUntilZero != null && daysUntilZero <= 7) {
      risk = ForecastRiskLevel.high;
    } else if (daysUntilZero != null && daysUntilZero <= 30) {
      risk = ForecastRiskLevel.medium;
    } else {
      risk = ForecastRiskLevel.low;
    }

    return ForecastResult(
      forecasts: predictions,
      lowestBalance: minBalance,
      daysUntilZero: daysUntilZero,
      riskLevel: risk,
    );
  }

  ForecastResult _simpleFallbackForecast(double currentBalance, int days) {
    // Very basic: Assume 0 net change (stable) if no data
    final predictions = <DailyForecast>[];
    final now = DateTime.now();

    for (int i = 1; i <= days; i++) {
      predictions.add(DailyForecast(
        date: now.add(Duration(days: i)),
        predictedBalance: currentBalance,
        lowerBound: currentBalance * 0.9,
        upperBound: currentBalance * 1.1,
      ));
    }

    return ForecastResult(
      forecasts: predictions,
      lowestBalance: currentBalance,
      riskLevel: ForecastRiskLevel.low,
    );
  }
}

class ForecastResult {
  final List<DailyForecast> forecasts;
  final double lowestBalance;
  final int? daysUntilZero;
  final ForecastRiskLevel riskLevel;

  ForecastResult({
    required this.forecasts,
    required this.lowestBalance,
    this.daysUntilZero,
    required this.riskLevel,
  });
}

class DailyForecast {
  final DateTime date;
  final double predictedBalance;
  final double lowerBound;
  final double upperBound;

  DailyForecast({
    required this.date,
    required this.predictedBalance,
    required this.lowerBound,
    required this.upperBound,
  });
}

enum ForecastRiskLevel { low, medium, high }
