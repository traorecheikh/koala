import 'dart:convert';
import 'package:get/get.dart';
// import 'package:hive_ce/hive.dart'; // Removed
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:logger/logger.dart';

/// Service for exporting financial data in various formats
class DataExportService extends GetxService {
  final _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _logger.i('DataExportService initialized');
  }

  /// Export all data as JSON
  Future<String> exportAsJson() async {
    try {
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'transactions': await _exportTransactions(),
        'budgets': await _exportBudgets(),
        'debts': await _exportDebts(),
        'goals': await _exportGoals(),
        'categories': await _exportCategories(),
      };

      return jsonEncode(data);
    } catch (e, st) {
      _logger.e('Failed to export as JSON', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Export all data as CSV
  Future<String> exportAsCSV() async {
    try {
      final buffer = StringBuffer();

      // Transactions CSV
      buffer.writeln('=== TRANSACTIONS ===');
      buffer.writeln('Date,Description,Category,Type,Amount');
      final allTx = await IsarService.getAllTransactions();
      for (var tx in allTx) {
        buffer.writeln(
          '${tx.date.toIso8601String()},${tx.description},${tx.categoryId},${tx.type},${tx.amount}',
        );
      }

      buffer.writeln('\n=== BUDGETS ===');
      buffer.writeln('Category,Amount,Year,Month');
      final allBudgets = await IsarService.getAllBudgets();
      for (var budget in allBudgets) {
        buffer.writeln(
          '${budget.categoryId},${budget.amount},${budget.year},${budget.month}',
        );
      }

      buffer.writeln('\n=== DEBTS ===');
      buffer.writeln('Person,Original Amount,Remaining,Type,Due Date');
      final allDebts = await IsarService.getAllDebts();
      for (var debt in allDebts) {
        buffer.writeln(
          '${debt.personName},${debt.originalAmount},${debt.remainingAmount},${debt.type},${debt.dueDate}',
        );
      }

      buffer.writeln('\n=== GOALS ===');
      buffer.writeln('Title,Target,Current,Status,Target Date');
      final allGoals = await IsarService.getAllGoals();
      for (var goal in allGoals) {
        buffer.writeln(
          '${goal.title},${goal.targetAmount},${goal.currentAmount},${goal.status},${goal.targetDate}',
        );
      }

      return buffer.toString();
    } catch (e, st) {
      _logger.e('Failed to export as CSV', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Get financial summary as formatted text
  Future<String> exportFinancialSummary() async {
    try {
      final allBudgets = await IsarService.getAllBudgets();
      final allDebts = await IsarService.getAllDebts();
      final allGoals = await IsarService.getAllGoals();

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      final allTx = await IsarService.getAllTransactions();

      for (var tx in allTx) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      double totalDebt = 0.0;
      for (var debt in allDebts) {
        if (!debt.isPaidOff) {
          totalDebt += debt.remainingAmount;
        }
      }

      final buffer = StringBuffer();
      buffer.writeln('FINANCIAL SUMMARY');
      buffer.writeln('Generated: ${DateTime.now()}');
      buffer.writeln('');
      buffer.writeln('INCOME & EXPENSES');
      buffer.writeln('Total Income: ${totalIncome.toStringAsFixed(2)} FCFA');
      buffer.writeln('Total Expenses: ${totalExpense.toStringAsFixed(2)} FCFA');
      buffer.writeln(
          'Net: ${(totalIncome - totalExpense).toStringAsFixed(2)} FCFA');
      buffer.writeln('');
      buffer.writeln('DEBTS');
      buffer.writeln('Total Outstanding: ${totalDebt.toStringAsFixed(2)} FCFA');
      buffer.writeln('Number of Debts: ${allDebts.length}');
      buffer.writeln('');
      buffer.writeln('GOALS');
      buffer.writeln('Total Goals: ${allGoals.length}');
      int completedGoals = 0;
      for (var goal in allGoals) {
        if (goal.status == GoalStatus.completed) {
          completedGoals++;
        }
      }
      buffer.writeln('Completed Goals: $completedGoals');
      buffer.writeln('');
      buffer.writeln('BUDGETS');
      buffer.writeln('Total Budgets: ${allBudgets.length}');

      return buffer.toString();
    } catch (e, st) {
      _logger.e('Failed to export summary', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Private helper methods
  Future<List<Map<String, dynamic>>> _exportTransactions() async {
    final allTx = await IsarService.getAllTransactions();
    return allTx.map((tx) => tx.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportBudgets() async {
    final allBudgets = await IsarService.getAllBudgets();
    return allBudgets
        .map((b) => {
              'id': b.id,
              'categoryId': b.categoryId,
              'amount': b.amount,
              'year': b.year,
              'month': b.month,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportDebts() async {
    final allDebts = await IsarService.getAllDebts();
    return allDebts
        .map((d) => {
              'id': d.id,
              'personName': d.personName,
              'originalAmount': d.originalAmount,
              'remainingAmount': d.remainingAmount,
              'type': d.type.toString(),
              'dueDate': d.dueDate?.toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportGoals() async {
    final allGoals = await IsarService.getAllGoals();
    return allGoals
        .map((g) => {
              'id': g.id,
              'title': g.title,
              'targetAmount': g.targetAmount,
              'currentAmount': g.currentAmount,
              'status': g.status.toString(),
              'targetDate': g.targetDate?.toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _exportCategories() async {
    final allCategories = await IsarService.getAllCategories();
    return allCategories
        .map((c) => {
              'id': c.id,
              'name': c.name,
              'icon': c.icon,
              'colorValue': c.colorValue,
              'type': c.type.toString(),
            })
        .toList();
  }
}
