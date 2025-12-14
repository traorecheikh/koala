
// Top-level background worker function for compute()
// Accepts a Map payload with keys: 'transactions' (List<Map>), 'currentBalance' (double)
// Returns a Map summary with lightweight results.

Map<String, dynamic> _analyzeTransactions(Map payload) {
  final List<dynamic> transactions = payload['transactions'] as List<dynamic>;
  final double currentBalance = (payload['currentBalance'] as num).toDouble();

  double totalIncome = 0.0;
  double totalExpense = 0.0;
  int daysSpan = 1;

  DateTime? minDate;
  DateTime? maxDate;

  for (final t in transactions) {
    try {
      final amount = (t['amount'] as num).toDouble();
      final type = t['type'] as String? ?? 'expense';
      final dateStr = t['date'] as String?;
      DateTime date = DateTime.now();
      if (dateStr != null) date = DateTime.parse(dateStr);

      minDate = minDate == null || date.isBefore(minDate) ? date : minDate;
      maxDate = maxDate == null || date.isAfter(maxDate) ? date : maxDate;

      if (type.contains('income')) {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    } catch (_) {
      continue;
    }
  }

  if (minDate != null && maxDate != null) {
    daysSpan = maxDate.difference(minDate).inDays;
    if (daysSpan <= 0) daysSpan = 1;
  }

  // Simple forecast heuristic: project end balance after 30 days using average daily net
  final dailyNet = (totalIncome - totalExpense) / daysSpan;
  final predictedEndBalance = currentBalance + dailyNet * 30.0;

  // Basic health score heuristic
  int healthScore = 100;
  if (dailyNet < 0) {
    healthScore = (80 + (dailyNet * 10)).clamp(0, 80).toInt();
  } else if (dailyNet < 10) {
    healthScore = (90 + (dailyNet)).clamp(60, 99).toInt();
  }

  return {
    'totalIncome': totalIncome,
    'totalExpense': totalExpense,
    'daysSpan': daysSpan,
    'predictedEndBalance': predictedEndBalance,
    'healthScore': healthScore,
  };
}

// compute() requires a top-level or static function, so expose a wrapper
Map<String, dynamic> analyzeTransactions(Map payload) => _analyzeTransactions(payload);


