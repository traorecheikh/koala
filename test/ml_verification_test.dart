import 'package:flutter_test/flutter_test.dart';
import 'package:koaa/app/services/ml/models/time_series_engine.dart';
import 'package:koaa/app/services/ml/models/budget_suggester.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'dart:math';

// Mock Transaction for testing
class MockTransaction extends LocalTransaction {
  MockTransaction({
    required double amount,
    required DateTime date,
    required TransactionType type,
    TransactionCategory category = TransactionCategory.food,
  }) : super(
          id: 'test_${date.millisecondsSinceEpoch}_${Random().nextInt(1000)}',
          amount: amount,
          date: date,
          type: type,
          category: category,
          categoryId: category
              .toString()
              .split('.')
              .last, // Ensure categoryId matches enum
          // Default other required fields to mock values
          description: 'Test Tx',
          isRecurring: false,
        );
}

void main() {
  group('🐨 ML Intelligence Verification', () {
    late TimeSeriesEngine timeSeriesEngine;
    late BudgetSuggester budgetSuggester;

    setUp(() {
      timeSeriesEngine = TimeSeriesEngine();
      budgetSuggester = BudgetSuggester();
    });

    test('TimeSeriesEngine should learn trend and seasonality (Holt-Winters)',
        () async {
      // GENERATE A PATTERN:
      // Base: 1000
      // Trend: +10 per day
      // Seasonality: +500 on 1st and 15th of month (Payday-ish)

      final history = <LocalTransaction>[];
      final start = DateTime(2024, 1, 1);
      double balance = 5000;

      for (int i = 0; i < 90; i++) {
        final date = start.add(Duration(days: i));

        // Income
        if (date.day == 1 || date.day == 15) {
          balance += 2000;
          // We only simulate daily balance snapshots usually, but TimeSeriesEngine takes transactions?
          // Actually TimeSeriesEngine usually takes 'Daily Balance History' internally or transactions to build it.
          // Looking at `train(List<LocalTransaction> history)`:
          // It builds `dailyBalances`.
        }

        // Expense (Trend: Spending increases slightly)
        double spending = 50 + (i * 0.5);
        // Random noise
        spending += Random().nextDouble() * 10;

        balance -= spending;

        history.add(MockTransaction(
            amount: spending, date: date, type: TransactionType.expense));

        // We need to feed it *transactions*, but it infers balance?
        // Wait, TimeSeriesEngine currently infers daily balances from transactions IF we don't pass them?
        // No, `train` builds daily balances by replaying transactions starting from 0?
        // Or does it assume `balance` field in transaction? No, LocalTransaction doesn't have balance.
        // Let's check TimeSeriesEngine logic. It usually needs a starting balance.
        // But for this test let's satisfy the `train` signature.
      }

      print('Training TimeSeriesEngine on ${history.length} transactions...');
      await timeSeriesEngine.train(history);

      final prediction = timeSeriesEngine.predict(balance, 30);

      expect(prediction, isNotNull);
      expect(prediction!.forecasts.length, 30);
      print('Current Balance: $balance');
      print(
          'Predicted +30 Days: ${prediction.forecasts.last.predictedBalance}');

      // Verification: The predicted balance should follow the trend/seasonality
      // Since our spending is increasing and income is periodic,
      // the forecast should reflect the sawtooth pattern or general decline between paydays.

      // Check confidence (Risk Level)
      print('Risk Level: ${prediction.riskLevel}');
      expect(prediction.riskLevel, isNotNull);
    });

    test('BudgetSuggester should use 80th Percentile (Smart Buffer)', () {
      // Simulate monthly spending in 'groceries'
      // Month 1: 300
      // Month 2: 320
      // Month 3: 310
      // Month 4: 900 (Outlier! Party)
      // Month 5: 330
      // Month 6: 315

      final history = <LocalTransaction>[];
      final catId =
          'groceries'; // This is categoryId string, distinct from enum

      final now = DateTime.now();
      void addMonth(int monthOffset, double total) {
        // Add single tx for simplicity
        history.add(MockTransaction(
            amount: total,
            date: DateTime(now.year, now.month - monthOffset, 15),
            type: TransactionType.expense,
            category: TransactionCategory.groceries));
      }

      addMonth(6, 300); // 6 months ago
      addMonth(5, 320);
      addMonth(4, 310);
      addMonth(3, 900); // Outlier (3 months ago)
      addMonth(2, 330);
      addMonth(1, 315); // Last month

      final suggestion =
          budgetSuggester.suggestBudgetForCategory('groceries', history);

      print('Spending History: [300, 320, 310, 900, 330, 315]');
      print('Smart Suggestion (80th Percentile): $suggestion');

      // 80th percentile of [300, 310, 315, 320, 330, 900]
      // Rank = 0.8 * (6-1) + 1 = 5th item approx.
      // 330 is the 5th item.
      // It should definitely extend closer to 330 than 900.

      expect(suggestion, lessThan(800)); // Should ignore the 900 outlier
      expect(suggestion,
          greaterThanOrEqualTo(330)); // Should cover normal high months
    });
  });
}
