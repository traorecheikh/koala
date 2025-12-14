import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/ml/financial_pattern.dart';

enum PatternType {
  recurringExpense,
  merchantHabit,
  monthlyCycle,
  spendingBurst,
}

class PatternRecognizer {
  List<FinancialPattern> detectPatterns(List<LocalTransaction> transactions) {
    final patterns = <FinancialPattern>[];

    // 1. Recurring Expenses (Subscriptions, Bills)
    // Same amount, approx same day of month
    final potentialRecurring = _findRecurring(transactions);
    patterns.addAll(potentialRecurring);

    // 2. Merchant Habits
    final merchantHabits = _findMerchantHabits(transactions);
    patterns.addAll(merchantHabits);

    // 3. End of Month Squeeze (Low balance trend at end of month)
    // _checkEndOfMonthSqueeze(transactions);

    return patterns;
  }

  List<FinancialPattern> _findRecurring(List<LocalTransaction> txs) {
    // Group by amount (fuzzy match?) and description
    final groups = <String, List<LocalTransaction>>{};
    
    for (var tx in txs) {
      if (tx.type != TransactionType.expense) continue;
      // Key: Amount rounded + Description (first 2 words)
      final key = '${tx.amount.round()}_${_getFirstWords(tx.description, 2)}';
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(tx);
    }

    final patterns = <FinancialPattern>[];

    groups.forEach((key, group) {
      if (group.length >= 3) {
        // Check intervals
        final intervals = <int>[];
        group.sort((a, b) => a.date.compareTo(b.date));
        
        for (int i = 0; i < group.length - 1; i++) {
          intervals.add(group[i+1].date.difference(group[i].date).inDays);
        }

        // Check if intervals are ~30 days (monthly) or ~7 days (weekly)
        final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
        
        if ((avgInterval - 30).abs() < 5) {
          patterns.add(FinancialPattern(
            patternType: PatternType.recurringExpense.name,
            description: 'Paiement mensuel probable: ${group.first.description}',
            confidence: 0.8,
            parameters: {
              'amount': group.first.amount.toString(),
              'interval': 'monthly',
              'avgDay': group.first.date.day.toString(),
            },
          ));
        } else if ((avgInterval - 7).abs() < 2) {
           patterns.add(FinancialPattern(
            patternType: PatternType.recurringExpense.name,
            description: 'Paiement hebdomadaire probable: ${group.first.description}',
            confidence: 0.7,
            parameters: {
              'amount': group.first.amount.toString(),
              'interval': 'weekly',
              'avgDay': group.first.date.weekday.toString(), // Store weekday (1-7)
            },
          ));
        }
      }
    });

    return patterns;
  }

  List<FinancialPattern> _findMerchantHabits(List<LocalTransaction> txs) {
    // Top merchants
    final counts = <String, int>{};
    for (var tx in txs) {
      if (tx.type == TransactionType.expense) {
        // Extract merchant name guess (first word?)
        final name = _getFirstWords(tx.description, 1).toUpperCase();
        if (name.length > 2) {
          counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }

    final patterns = <FinancialPattern>[];
    counts.forEach((name, count) {
      if (count > 5) {
        patterns.add(FinancialPattern(
          patternType: PatternType.merchantHabit.name,
          description: 'Habitué chez $name',
          confidence: 0.7,
          parameters: {
            'merchantName': name,
            'visitsPerMonth': (count / 3).toStringAsFixed(1), // approx if 3 months data
          },
        ));
      }
    });

    return patterns;
  }

  String _getFirstWords(String text, int count) {
    final words = text.split(' ');
    if (words.length <= count) return text;
    return words.take(count).join(' ');
  }
}

