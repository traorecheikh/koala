import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/local_transaction.dart';

/// Service for managing Isar database instance.
/// Handles initialization and provides access to the Isar instance.
class IsarService {
  static Isar? _isar;
  static bool _isInitialized = false;

  /// Get the Isar instance. Throws if not initialized.
  static Isar get instance {
    if (_isar == null) {
      throw StateError('IsarService not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Check if Isar is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Isar with required schemas
  static Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();
    
    _isar = Isar.open(
      schemas: [LocalTransactionSchema],
      directory: dir.path,
      name: 'koala_isar',
    );
    
    _isInitialized = true;
  }

  /// Close the Isar instance
  static Future<void> close() async {
    _isar?.close();
    _isar = null;
    _isInitialized = false;
  }

  /// Get the LocalTransaction collection
  static IsarCollection<String, LocalTransaction> get transactions {
    return instance.localTransactions;
  }

  /// Add a transaction (synchronous write for isolate compatibility)
  static void addTransaction(LocalTransaction transaction) {
    instance.write((isar) {
      isar.localTransactions.put(transaction);
    });
  }

  /// Add multiple transactions (synchronous for migration compatibility)
  static void addTransactions(List<LocalTransaction> txns) {
    instance.write((isar) {
      isar.localTransactions.putAll(txns);
    });
  }

  /// Update a transaction
  static void updateTransaction(LocalTransaction transaction) {
    instance.write((isar) {
      isar.localTransactions.put(transaction);
    });
  }

  /// Delete a transaction by ID
  static bool deleteTransaction(String id) {
    bool deleted = false;
    instance.write((isar) {
      deleted = isar.localTransactions.delete(id);
    });
    return deleted;
  }

  /// Get all transactions
  static Future<List<LocalTransaction>> getAllTransactions() async {
    return await transactions.where().findAllAsync();
  }

  /// Get transactions by date range (uses filter on results)
  static Future<List<LocalTransaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final all = await transactions.where().findAllAsync();
    return all.where((tx) =>
      tx.date.isAfter(start.subtract(const Duration(days: 1))) &&
      tx.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  /// Watch all transactions for changes
  static Stream<List<LocalTransaction>> watchTransactions() {
    return transactions.where().watch(fireImmediately: true);
  }

  /// Get transaction count
  static Future<int> getTransactionCount() async {
    final all = await transactions.where().findAllAsync();
    return all.length;
  }

  /// Clear all transactions (for testing/reset)
  static void clearTransactions() {
    instance.write((isar) {
      isar.localTransactions.clear();
    });
  }
}
