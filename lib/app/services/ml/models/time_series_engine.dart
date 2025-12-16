import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/ml/feature_extractor.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';

class TimeSeriesEngine {
  final FeatureExtractor _featureExtractor;

  LinearRegressor? _trendModel;
  bool _isTrained = false;

  TimeSeriesEngine(this._featureExtractor);

  Future<void> train(List<LocalTransaction> history) async {
    if (history.length < 30) return;

    // Aggregate daily net cash flow
    final dailyFlow = <DateTime, double>{};
    for (final tx in history) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final amount = tx.type == TransactionType.income ? tx.amount : -tx.amount;
      dailyFlow[date] = (dailyFlow[date] ?? 0) + amount;
    }

    final sortedDates = dailyFlow.keys.toList()..sort();
    if (sortedDates.isEmpty) return;

    final dataRows = <List<dynamic>>[];

    // Calculate cumulative balance (approximate)
    double balance = 0;
    final start = sortedDates.first;

    for (final date in sortedDates) {
      balance += dailyFlow[date]!;

      final daysSinceStart = date.difference(start).inDays.toDouble();
      // Features: Days, DayOfWeek, Month + Target (balance)
      dataRows.add([
        daysSinceStart,
        date.weekday.toDouble(),
        date.month.toDouble(),
        balance
      ]);
    }

    if (dataRows.isEmpty) return;

    try {
      final dataFrame = DataFrame(dataRows,
          headerExists: false, columnNames: ['days', 'dow', 'month', 'target']);

      _trendModel = LinearRegressor(dataFrame, 'target');
      _isTrained = true;
    } catch (e) {
      print('Forecasting training failed: $e');
    }
  }

  /// Predict future balances for the next N days
  /// Returns a ForecastResult with daily predictions, risk assessment, and key metrics
  ForecastResult predict(double currentBalance, int days) {
    if (!_isTrained || _trendModel == null) {
      // Fallback: simple linear extrapolation based on recent daily change
      return _simpleFallbackForecast(currentBalance, days);
    }

    final predictions = <DailyForecast>[];
    final now = DateTime.now();
    double minBalance = currentBalance;
    int? daysUntilZero;

    // Step 1: Get the model's prediction for "today" to calculate offset
    // We use the training day count as our baseline
    final todayFeatures = DataFrame(
      [
        [0.0, now.weekday.toDouble(), now.month.toDouble()]
      ],
      headerExists: false,
      columnNames: ['days', 'dow', 'month'],
    );

    double offset = currentBalance;
    try {
      final todayPrediction = _trendModel!.predict(todayFeatures);
      final predictedToday = todayPrediction.rows.first.first as double;
      offset = currentBalance - predictedToday;
    } catch (e) {
      // If prediction fails, just use currentBalance as baseline
    }

    // Step 2: Predict each future day
    for (int i = 1; i <= days; i++) {
      final date = now.add(Duration(days: i));

      // Create feature DataFrame for this day
      final features = DataFrame(
        [
          [i.toDouble(), date.weekday.toDouble(), date.month.toDouble()]
        ],
        headerExists: false,
        columnNames: ['days', 'dow', 'month'],
      );

      double predictedBalance = currentBalance;
      try {
        final prediction = _trendModel!.predict(features);
        predictedBalance = (prediction.rows.first.first as double) + offset;
      } catch (e) {
        // On error, use linear extrapolation from last known point
        final lastBalance = predictions.isNotEmpty
            ? predictions.last.predictedBalance
            : currentBalance;
        predictedBalance = lastBalance; // Simple: assume flat if model fails
      }

      // Calculate uncertainty bounds (±10% for simplicity, or based on residuals)
      final uncertainty = predictedBalance.abs() * 0.10;
      final lowerBound = predictedBalance - uncertainty;
      final upperBound = predictedBalance + uncertainty;

      predictions.add(DailyForecast(
        date: date,
        predictedBalance: predictedBalance,
        lowerBound: lowerBound,
        upperBound: upperBound,
      ));

      // Track minimum balance
      if (predictedBalance < minBalance) {
        minBalance = predictedBalance;
      }

      // Track first day balance goes negative
      if (predictedBalance <= 0 && daysUntilZero == null) {
        daysUntilZero = i;
      }
    }

    // Determine risk level based on predictions
    ForecastRiskLevel riskLevel;
    if (daysUntilZero != null && daysUntilZero <= 14) {
      riskLevel = ForecastRiskLevel.high;
    } else if (minBalance < currentBalance * 0.2) {
      riskLevel = ForecastRiskLevel.medium;
    } else {
      riskLevel = ForecastRiskLevel.low;
    }

    return ForecastResult(
      forecasts: predictions,
      lowestBalance: minBalance,
      daysUntilZero: daysUntilZero,
      riskLevel: riskLevel,
    );
  }

  /// Simple fallback when model not trained: assume constant daily burn rate
  ForecastResult _simpleFallbackForecast(double currentBalance, int days) {
    final predictions = <DailyForecast>[];
    final now = DateTime.now();

    // Assume 1% daily decline as conservative estimate
    final dailyBurnRate = currentBalance * 0.01;
    double balance = currentBalance;
    double minBalance = currentBalance;
    int? daysUntilZero;

    for (int i = 1; i <= days; i++) {
      final date = now.add(Duration(days: i));
      balance -= dailyBurnRate;

      if (balance < minBalance) minBalance = balance;
      if (balance <= 0 && daysUntilZero == null) daysUntilZero = i;

      predictions.add(DailyForecast(
        date: date,
        predictedBalance: balance,
        lowerBound: balance * 0.9,
        upperBound: balance * 1.1,
      ));
    }

    return ForecastResult(
      forecasts: predictions,
      lowestBalance: minBalance,
      daysUntilZero: daysUntilZero,
      riskLevel: daysUntilZero != null
          ? ForecastRiskLevel.medium
          : ForecastRiskLevel.low,
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
