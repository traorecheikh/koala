import 'package:koaa/app/data/models/local_transaction.dart';

/// Payload for the worker
class ContextualTrainPayload {
  final List<Map<String, dynamic>> rawTransactions;

  ContextualTrainPayload(this.rawTransactions);
}

/// Result from the worker
class ContextualTrainResult {
  final Map<String, Map<String, int>> matrix;
  final Map<String, List<double>> amountHistory;

  ContextualTrainResult(this.matrix, this.amountHistory);
}

/// Top-level function for compute()
ContextualTrainResult trainContextualBrain(ContextualTrainPayload payload) {
  final matrix = <String, Map<String, int>>{};
  final amountHistory = <String, List<double>>{};

  for (final tData in payload.rawTransactions) {
    // Deserialize minimal needed data
    final categoryId = tData['categoryId'] as String?;
    if (categoryId == null) continue;

    final type = tData['type'] as String? ?? 'expense';
    if (type != 'expense') continue;

    final amount = (tData['amount'] as num).toDouble();
    final dateStr = tData['date'] as String?;
    if (dateStr == null) continue;

    final date = DateTime.parse(dateStr);

    // Feature extraction key
    final day = date.weekday;
    final hour = date.hour;
    final key = '$day-$hour';

    // Update Matrix
    if (!matrix.containsKey(key)) {
      matrix[key] = {};
    }
    matrix[key]![categoryId] = (matrix[key]![categoryId] ?? 0) + 1;

    // Update Amount History
    final amountKey = '$key-$categoryId';
    if (!amountHistory.containsKey(amountKey)) {
      amountHistory[amountKey] = [];
    }
    amountHistory[amountKey]!.add(amount);
  }

  return ContextualTrainResult(matrix, amountHistory);
}
