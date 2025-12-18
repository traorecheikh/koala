import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:hive_ce/hive.dart';

/// Service for managing transaction history and undo/redo operations
class TransactionHistoryService extends GetxService {
  final _undoStack = <TransactionHistoryEntry>[].obs;
  final _redoStack = <TransactionHistoryEntry>[].obs;

  static const int maxHistorySize = 100;

  /// Record a transaction addition for undo capability
  void recordTransactionAdded(LocalTransaction transaction) {
    _undoStack.add(
      TransactionHistoryEntry(
        timestamp: DateTime.now(),
        transaction: transaction,
        action: HistoryAction.added,
      ),
    );

    // Clear redo stack when new action is performed
    _redoStack.clear();

    // Limit history size
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// Record a transaction deletion for undo capability
  void recordTransactionDeleted(LocalTransaction transaction) {
    _undoStack.add(
      TransactionHistoryEntry(
        timestamp: DateTime.now(),
        transaction: transaction,
        action: HistoryAction.deleted,
      ),
    );

    _redoStack.clear();

    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// Record a transaction modification for undo capability
  void recordTransactionModified(
    LocalTransaction oldTransaction,
    LocalTransaction newTransaction,
  ) {
    _undoStack.add(
      TransactionHistoryEntry(
        timestamp: DateTime.now(),
        transaction: oldTransaction, // Store old version for undo
        action: HistoryAction.modified,
        newData: newTransaction,
      ),
    );

    _redoStack.clear();

    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// Undo the last transaction operation
  Future<bool> undo() async {
    if (_undoStack.isEmpty) return false;

    try {
      final entry = _undoStack.removeLast();
      final box = Hive.box<LocalTransaction>('transactionBox');

      switch (entry.action) {
        case HistoryAction.added:
          // Remove the added transaction
          await box.delete(entry.transaction.id);
          _redoStack.add(entry);
          break;

        case HistoryAction.deleted:
          // Restore the deleted transaction
          await box.put(entry.transaction.id, entry.transaction);
          _redoStack.add(entry);
          break;

        case HistoryAction.modified:
          // Restore the old version
          await box.put(entry.transaction.id, entry.transaction);
          _redoStack.add(entry);
          break;
      }

      return true;
    } catch (e) {
      // Log error and return false
      return false;
    }
  }

  /// Redo the last undone transaction operation
  Future<bool> redo() async {
    if (_redoStack.isEmpty) return false;

    try {
      final entry = _redoStack.removeLast();
      final box = Hive.box<LocalTransaction>('transactionBox');

      switch (entry.action) {
        case HistoryAction.added:
          // Re-add the transaction
          await box.put(entry.transaction.id, entry.transaction);
          _undoStack.add(entry);
          break;

        case HistoryAction.deleted:
          // Re-delete the transaction
          await box.delete(entry.transaction.id);
          _undoStack.add(entry);
          break;

        case HistoryAction.modified:
          // Apply the new version again
          if (entry.newData != null) {
            await box.put(entry.newData!.id, entry.newData!);
          }
          _undoStack.add(entry);
          break;
      }

      return true;
    } catch (e) {
      // Log error and return false
      return false;
    }
  }

  /// Check if undo is available
  bool get canUndo => _undoStack.isNotEmpty;

  /// Check if redo is available
  bool get canRedo => _redoStack.isNotEmpty;

  /// Get recent history entries
  List<TransactionHistoryEntry> getRecentHistory([int limit = 10]) {
    return _undoStack.length > limit
        ? _undoStack.sublist(_undoStack.length - limit)
        : _undoStack;
  }

  /// Clear all history
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

/// Transaction history entry
class TransactionHistoryEntry {
  final DateTime timestamp;
  final LocalTransaction transaction;
  final HistoryAction action;
  final LocalTransaction? newData; // For modified entries

  TransactionHistoryEntry({
    required this.timestamp,
    required this.transaction,
    required this.action,
    this.newData,
  });
}

enum HistoryAction { added, deleted, modified }
