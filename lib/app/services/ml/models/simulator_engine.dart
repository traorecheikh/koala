import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/recurring_transaction.dart';
import 'package:koaa/app/services/ml/models/time_series_engine.dart';
import 'package:intl/intl.dart'; // Added import

class SimulatorEngine {
  final TimeSeriesEngine _timeSeriesEngine;

  SimulatorEngine(this._timeSeriesEngine);

  /// Simulate cash flow impact of a proposed expense
  SimulationResult simulatePurchase({
    required double currentBalance,
    required double purchaseAmount,
    required List<RecurringTransaction> recurringBills,
    required List<LocalTransaction> recentHistory,
    int daysToSimulate = 30,
  }) {
    double simulatedBalance = currentBalance - purchaseAmount;
    final now = DateTime.now();
    DateTime? zeroBalanceDate;
    double lowestBalance = simulatedBalance;
    String? reasonForRisk;
    double initialBalanceAfterPurchase = simulatedBalance;

    // Calculate daily average organic spending (excluding large recurring bills)
    double dailyBurnRate = _calculateDailyBurnRate(recentHistory, recurringBills);

    for (int i = 1; i <= daysToSimulate; i++) {
      final date = now.add(Duration(days: i));
      
      // Subtract organic spending
      simulatedBalance -= dailyBurnRate;

      // Subtract recurring bills due on this day
      for (final bill in recurringBills) {
        if (_isBillDueOn(bill, date)) {
          simulatedBalance -= bill.amount;
          if (simulatedBalance <= 0 && reasonForRisk == null) {
            reasonForRisk = 'Le paiement de la facture "${bill.description}"';
          }
        }
      }

      // Track lowest balance and first zero balance date
      if (simulatedBalance < lowestBalance) {
        lowestBalance = simulatedBalance;
      }
      if (simulatedBalance <= 0 && zeroBalanceDate == null) {
        zeroBalanceDate = date;
      }
    }

    final isSafe = lowestBalance >= 0;
    
    // Determine the actual margin/deficit
    double finalMargin = lowestBalance;
    if (lowestBalance < 0 && reasonForRisk == null) {
        reasonForRisk = 'Dépenses quotidiennes';
    }

    // Identify upcoming bills in the simulation window
    final upcomingBills = recurringBills.where((bill) {
      for (int i = 1; i <= daysToSimulate; i++) {
        if (_isBillDueOn(bill, now.add(Duration(days: i)))) return true;
      }
      return false;
    }).toList();

    return SimulationResult(
      isSafe: isSafe,
      lowestBalance: lowestBalance,
      daysUntilBroke: zeroBalanceDate != null ? zeroBalanceDate.difference(now).inDays : null,
      surplus: isSafe ? finalMargin : 0,
      deficit: !isSafe ? finalMargin.abs() : 0,
      dailyBurnRate: dailyBurnRate,
      upcomingBills: upcomingBills,
      explanation: SimulationExplanation(
        mainImpact: isSafe 
            ? 'Vous pouvez effectuer cet achat en toute sécurité.'
            : 'Cet achat risque de vous mettre en difficulté financière.',
        details: isSafe
            ? 'Après avoir effectué l\'achat, votre solde ne descendra pas en dessous de ${NumberFormat.compact().format(lowestBalance)} F sur les 30 prochains jours.'
            : '${reasonForRisk ?? "Vos dépenses"} risquent de vous faire passer à découvert. Votre solde pourrait devenir négatif dans les 30 prochains jours.',
        criticalPoint: !isSafe && zeroBalanceDate != null
            ? 'Vous pourriez atteindre un solde nul ou négatif aux alentours du ${DateFormat('dd MMM').format(zeroBalanceDate)}.'
            : null,
      ),
    );
  }

  double _calculateDailyBurnRate(List<LocalTransaction> history, List<RecurringTransaction> bills) {
    if (history.isEmpty) return 0;

    // Filter for expenses, exclude amounts close to known recurring bills
    final nonBillExpenses = history.where((t) {
      if (t.type != TransactionType.expense) return false;
      // Check if this transaction is likely a recurring bill
      return !bills.any((bill) => (t.amount - bill.amount).abs() < t.amount * 0.1 && // Amount is similar
                                   t.date.difference(bill.lastGeneratedDate).inDays.abs() < 10); // Around bill date
    }).toList();
    
    if (nonBillExpenses.isEmpty) return 0;

    final totalNonBillSpend = nonBillExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final distinctDays = nonBillExpenses.map((t) => DateTime(t.date.year, t.date.month, t.date.day)).toSet().length;

    // A more robust burn rate: total non-bill expenses / number of days with such expenses
    return totalNonBillSpend / (distinctDays > 0 ? distinctDays : 1);
  }

  bool _isBillDueOn(RecurringTransaction bill, DateTime date) {
    if (bill.frequency == Frequency.monthly) {
      return date.day == bill.dayOfMonth;
    }
    // TODO: Handle weekly bills properly
    return false;
  }
}

class SimulationResult {
  final bool isSafe;
  final double lowestBalance;
  final int? daysUntilBroke;
  final double surplus;
  final double deficit;
  final double dailyBurnRate;
  final List<RecurringTransaction> upcomingBills;
  final SimulationExplanation explanation;

  SimulationResult({
    required this.isSafe,
    required this.lowestBalance,
    this.daysUntilBroke,
    required this.surplus,
    required this.deficit,
    required this.dailyBurnRate,
    required this.upcomingBills,
    required this.explanation,
  });
}

class SimulationExplanation {
  final String mainImpact;
  final String details;
  final String? criticalPoint;

  SimulationExplanation({
    required this.mainImpact,
    required this.details,
    this.criticalPoint,
  });
}
