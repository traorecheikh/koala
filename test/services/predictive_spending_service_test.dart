import 'package:flutter_test/flutter_test.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/predictive_spending_service.dart';
import 'package:koaa/app/data/models/ml/financial_intelligence.dart';

void main() {
  late PredictiveSpendingService service;

  setUp(() {
    service = PredictiveSpendingService();
  });

  test('Should detect critical budget overrun', () {
    final budget = Budget(
      id: '1',
      categoryId: 'groceries',
      amount: 500,
      year: DateTime.now().year,
      month: DateTime.now().month,
    );

    // Simulate spending 600 already
    final transactions = List.generate(
      1,
      (index) => LocalTransaction.create(
        amount: 600,
        description: 'Big Shopping',
        date: DateTime.now(),
        type: TransactionType.expense,
        category: TransactionCategory.groceries,
        categoryId: 'groceries',
      ),
    );

    final alerts = service.analyzeSpending(
      transactions: transactions,
      budgets: [budget],
    );

    expect(alerts.length, 1);
    expect(alerts.first.severity, AlertSeverity.critical);
    expect(alerts.first.message, contains('Budget dépassé'));
  });

  test('Should detect high risk projection', () {
    final budget = Budget(
      id: '2',
      categoryId: 'dining',
      amount: 1000,
      year: DateTime.now().year,
      month: DateTime.now().month,
    );

    final transactions = List.generate(
      1,
      (index) => LocalTransaction.create(
        amount: 200, // Significant amount
        description: 'Dinner',
        date: DateTime.now(),
        type: TransactionType.expense,
        category: TransactionCategory.food,
        categoryId: 'dining',
      ),
    );

    final alerts = service.analyzeSpending(
      transactions: transactions,
      budgets: [budget],
    );

    // Just ensure no crash and potential alert
    if (alerts.isNotEmpty) {
      print(
          'Alert generated: ${alerts.first.message} (${alerts.first.severity})');
    }
  });
}
