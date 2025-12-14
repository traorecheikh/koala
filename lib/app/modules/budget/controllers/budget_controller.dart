import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/budget.dart';
import 'package:koaa/app/data/models/category.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:uuid/uuid.dart';

enum BudgetStatus { safe, warning, exceeded, critical }
enum Trend { improving, stable, worsening }

class BudgetController extends GetxController {
  final budgets = <Budget>[].obs;
  final categories = <Category>[].obs;
  final transactions = <LocalTransaction>[].obs;

  late FinancialContextService _financialContextService;
  late FinancialEventsService _financialEventsService;
  final List<Worker> _workers = []; // List to store workers for disposal

  @override
  void onInit() {
    super.onInit();
    _financialContextService = Get.find<FinancialContextService>();
    _financialEventsService = Get.find<FinancialEventsService>();
    
    // Listen to changes from FinancialContextService and store workers
    _workers.add(ever(_financialContextService.allBudgets, (_) => budgets.assignAll(_financialContextService.allBudgets)));
    _workers.add(ever(_financialContextService.allCategories, (_) => categories.assignAll(_financialContextService.allCategories)));
    _workers.add(ever(_financialContextService.allTransactions, (_) => transactions.assignAll(_financialContextService.allTransactions)));

    // Initial load from context service
    budgets.assignAll(_financialContextService.allBudgets);
    categories.assignAll(_financialContextService.allCategories);
    transactions.assignAll(_financialContextService.allTransactions);
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  double getSpentAmount(String categoryId) {
    final now = DateTime.now();
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    
    if (category?.type == TransactionType.income) {
       final start = DateTime(now.year, now.month, 1);
       final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
       return transactions
          .where((t) => 
              t.categoryId == categoryId && 
              t.type == TransactionType.income &&
              t.date.isAfter(start) && 
              t.date.isBefore(end))
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    
    return _financialContextService.getSpentAmountForCategory(categoryId, now.year, now.month);
  }

  Category? getCategory(String id) {
    return _financialContextService.getCategoryById(id);
  }

  Future<void> addBudget(String categoryId, double amount) async {
    try {
      final box = Hive.box<Budget>('budgetBox');
      final now = DateTime.now();
      // Check if budget exists for category for current month/year
      final existing = budgets.firstWhereOrNull((b) =>
        b.categoryId == categoryId && b.year == now.year && b.month == now.month
      );
      if (existing != null) {
        existing.amount = amount;
        await existing.save();
        Get.snackbar(
          'Succès',
          'Budget mis à jour',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final budget = Budget(
          id: const Uuid().v4(),
          categoryId: categoryId,
          amount: amount,
          year: now.year,
          month: now.month,
        );
        await box.put(budget.id, budget);
        Get.snackbar(
          'Succès',
          'Budget créé',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de gérer le budget: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  double getSuggestedBudget(String categoryId) {
    final engine = Get.find<KoalaMLEngine>();
    return engine.suggestBudgetForCategory(categoryId, transactions.toList());
  }

  // --- New Methods for Enhanced Integration ---

  // Detailed budget vs actual with trends
  double getBudgetPerformance(String categoryId, int year, int month) {
    final budgeted = _financialContextService.getBudgetedAmountForCategory(categoryId, year, month);
    final spent = _financialContextService.getSpentAmountForCategory(categoryId, year, month);
    return budgeted - spent; // Positive means under budget, negative means over
  }

  // Connect budget savings to goals
  Future<void> linkBudgetToGoal(String categoryId, String goalId) async {
    try {
      final goalBox = Hive.box<FinancialGoal>('financialGoalBox');
      final goal = goalBox.get(goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(linkedCategoryId: categoryId);
        await goalBox.put(updatedGoal.id, updatedGoal);
        Get.snackbar(
          'Succès',
          'Budget lié à l\'objectif',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Objectif non trouvé',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de lier le budget: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Total allocated budget for a given month/year
  double getMonthlyBudgetTotal(int year, int month) {
    return budgets
        .where((b) => b.year == year && b.month == month)
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  // Budget status tracking: safe, warning, exceeded, critical
  BudgetStatus getBudgetStatus(String categoryId, int year, int month) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    final isIncome = category?.type == TransactionType.income;

    final budgeted = _financialContextService.getBudgetedAmountForCategory(categoryId, year, month);
    if (budgeted == 0) return BudgetStatus.safe;

    double actual = 0.0;

    if (isIncome) {
       // For income, sum up earnings
       final start = DateTime(year, month, 1);
       final end = DateTime(year, month + 1, 0, 23, 59, 59);
       actual = transactions
          .where((t) =>
              t.categoryId == categoryId &&
              t.type == TransactionType.income &&
              t.date.isAfter(start) &&
              t.date.isBefore(end))
          .fold(0.0, (sum, t) => sum + t.amount);
    } else {
       // For expenses, get spent amount
       actual = _financialContextService.getSpentAmountForCategory(categoryId, year, month);
    }

    final percentage = (actual / budgeted) * 100;
    final budget = budgets.firstWhereOrNull((b) => b.categoryId == categoryId && b.year == year && b.month == month);

    if (isIncome) {
       // INCOME LOGIC: Higher is better (reaching income target)
       // 100%+ = exceeded target (safe/good)
       // 80-99% = on track (safe - close to target)
       // 0-79% = behind target (critical - far from target)
       if (percentage >= 100) {
         return BudgetStatus.exceeded; // Exceeded income target (positive outcome)
       } else if (percentage >= 80) {
         return BudgetStatus.safe; // On track, close to target (Positive)
       } else {
         return BudgetStatus.critical; // Behind income target
       }
    } else {
       // EXPENSE LOGIC: Lower is better (staying under expense limit)
       // 0-79% = safe (well under budget)
       // 80-99% = warning (approaching limit)
       // 100%+ = exceeded (over budget)
       if (percentage >= 100) {
         if (budget != null) {
            _financialEventsService.emitBudgetExceeded(
               budgetId: budget.id,
               categoryId: categoryId,
               overshootAmount: actual - budgeted
             );
         }
         return BudgetStatus.exceeded; // Over expense budget (negative outcome)
       } else if (percentage >= 80) {
          if (budget != null) {
             _financialEventsService.emitBudgetApproachingLimit(
               budgetId: budget.id,
               categoryId: categoryId,
               percentageSpent: percentage
             );
          }
         return BudgetStatus.warning; // Approaching expense limit
       } else {
         return BudgetStatus.safe; // Well under expense budget (positive outcome)
       }
    }
  }

  // Trend analysis: improving, stable, worsening
  Trend getBudgetTrend(String categoryId) {
    final now = DateTime.now();
    final currentMonthPerformance = getBudgetPerformance(categoryId, now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final previousMonthPerformance = getBudgetPerformance(categoryId, previousMonth.year, previousMonth.month);

    if (currentMonthPerformance > previousMonthPerformance) {
      return Trend.improving;
    } else if (currentMonthPerformance < previousMonthPerformance) {
      return Trend.worsening;
    } else {
      return Trend.stable;
    }
  }
}


