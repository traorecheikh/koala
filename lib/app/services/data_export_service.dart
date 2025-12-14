import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/debt.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/category.dart';
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
      final txBox = Hive.box<LocalTransaction>('transactionBox');
      for (var tx in txBox.values) {
        buffer.writeln(
          '${tx.date.toIso8601String()},${tx.description},${tx.categoryId},${tx.type},${tx.amount}',
        );
      }

      buffer.writeln('\n=== BUDGETS ===');
      buffer.writeln('Category,Amount,Year,Month');
      final budgetBox = Hive.box<Budget>('budgetBox');
      for (var budget in budgetBox.values) {
        buffer.writeln(
          '${budget.categoryId},${budget.amount},${budget.year},${budget.month}',
        );
      }

      buffer.writeln('\n=== DEBTS ===');
      buffer.writeln('Person,Original Amount,Remaining,Type,Due Date');
      final debtBox = Hive.box<Debt>('debtBox');
      for (var debt in debtBox.values) {
        buffer.writeln(
          '${debt.personName},${debt.originalAmount},${debt.remainingAmount},${debt.type},${debt.dueDate}',
        );
      }

      buffer.writeln('\n=== GOALS ===');
      buffer.writeln('Title,Target,Current,Status,Target Date');
      final goalBox = Hive.box<FinancialGoal>('financialGoalBox');
      for (var goal in goalBox.values) {
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
      final txBox = Hive.box<LocalTransaction>('transactionBox');
      final budgetBox = Hive.box<Budget>('budgetBox');
      final debtBox = Hive.box<Debt>('debtBox');
      final goalBox = Hive.box<FinancialGoal>('financialGoalBox');

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      for (var tx in txBox.values) {
        if (tx.type == TransactionType.income) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }

      double totalDebt = 0.0;
      for (var debt in debtBox.values) {
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
      buffer.writeln('Net: ${(totalIncome - totalExpense).toStringAsFixed(2)} FCFA');
      buffer.writeln('');
      buffer.writeln('DEBTS');
      buffer.writeln('Total Outstanding: ${totalDebt.toStringAsFixed(2)} FCFA');
      buffer.writeln('Number of Debts: ${debtBox.length}');
      buffer.writeln('');
      buffer.writeln('GOALS');
      buffer.writeln('Total Goals: ${goalBox.length}');
      int completedGoals = 0;
      for (var goal in goalBox.values) {
        if (goal.status == GoalStatus.completed) {
          completedGoals++;
        }
      }
      buffer.writeln('Completed Goals: $completedGoals');
      buffer.writeln('');
      buffer.writeln('BUDGETS');
      buffer.writeln('Total Budgets: ${budgetBox.length}');

      return buffer.toString();
    } catch (e, st) {
      _logger.e('Failed to export summary', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Private helper methods
  Future<List<Map<String, dynamic>>> _exportTransactions() async {
    final box = Hive.box<LocalTransaction>('transactionBox');
    return box.values.map((tx) => tx.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> _exportBudgets() async {
    final box = Hive.box<Budget>('budgetBox');
    return box.values.map((b) => {
          'id': b.id,
          'categoryId': b.categoryId,
          'amount': b.amount,
          'year': b.year,
          'month': b.month,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportDebts() async {
    final box = Hive.box<Debt>('debtBox');
    return box.values.map((d) => {
          'id': d.id,
          'personName': d.personName,
          'originalAmount': d.originalAmount,
          'remainingAmount': d.remainingAmount,
          'type': d.type.toString(),
          'dueDate': d.dueDate?.toIso8601String(),
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportGoals() async {
    final box = Hive.box<FinancialGoal>('financialGoalBox');
    return box.values.map((g) => {
          'id': g.id,
          'title': g.title,
          'targetAmount': g.targetAmount,
          'currentAmount': g.currentAmount,
          'status': g.status.toString(),
          'targetDate': g.targetDate?.toIso8601String(),
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportCategories() async {
    final box = Hive.box<Category>('categoryBox');
    return box.values.map((c) => {
          'id': c.id,
          'name': c.name,
          'icon': c.icon,
          'colorValue': c.colorValue,
          'type': c.type.toString(),
        }).toList();
  }
}

