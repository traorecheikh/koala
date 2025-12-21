import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'dart:async'; // Added import for StreamSubscription

class GoalsController extends GetxController {
  final financialGoals = <FinancialGoal>[].obs;
  // late Box<FinancialGoal> _goalBox; // Removed Hive Box
  late FinancialContextService _financialContextService;
  late FinancialEventsService _financialEventsService;
  late StreamSubscription _isarGoalsSubscription;
  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    _financialContextService = Get.find<FinancialContextService>();
    _financialEventsService = Get.find<FinancialEventsService>();

    // Initial load
    IsarService.getAllGoals().then((goals) {
      financialGoals.assignAll(goals);
    });

    _workers.add(ever(_financialContextService.allTransactions,
        (_) => _updateGoalProgress()));
    _isarGoalsSubscription = IsarService.watchGoals().listen((goals) {
      financialGoals.assignAll(goals);
    });
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    _isarGoalsSubscription.cancel();
    super.onClose();
  }

  // Getters for filtered goals
  List<FinancialGoal> get activeGoals =>
      financialGoals.where((goal) => goal.status == GoalStatus.active).toList();

  List<FinancialGoal> get completedGoals => financialGoals
      .where((goal) => goal.status == GoalStatus.completed)
      .toList();

  List<FinancialGoal> get pausedGoals =>
      financialGoals.where((goal) => goal.status == GoalStatus.paused).toList();

  List<FinancialGoal> get abandonedGoals => financialGoals
      .where((goal) => goal.status == GoalStatus.abandoned)
      .toList();

  // CRUD operations
  Future<void> addGoal(FinancialGoal goal) async {
    try {
      IsarService.addGoal(goal); // Sync call
      // financialGoals.add(goal); // Handled by watcher
      _updateGoalProgress();
      Get.snackbar(
        'Succès',
        'Objectif ajouté avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter l\'objectif: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateGoal(FinancialGoal updatedGoal) async {
    try {
      IsarService.updateGoal(updatedGoal);
      // Watched automatically
      _updateGoalProgress();
      Get.snackbar(
        'Succès',
        'Objectif mis à jour avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour l\'objectif: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      IsarService.deleteGoal(goalId);
      // Handled by watcher
      Get.snackbar(
        'Succès',
        'Objectif supprimé avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer l\'objectif: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> setGoalStatus(String goalId, GoalStatus status) async {
    try {
      final goal = await IsarService.getGoalById(goalId);
      if (goal != null) {
        final updatedGoal = goal.copyWith(status: status);
        if (status == GoalStatus.completed) {
          updatedGoal.completedAt = DateTime.now();
          _financialEventsService
              .emit(GoalEvent(FinancialEventType.goalCompleted, updatedGoal));
        } else if (status == GoalStatus.abandoned) {
          updatedGoal.completedAt = null;
          _financialEventsService
              .emit(GoalEvent(FinancialEventType.goalAbandoned, updatedGoal));
        } else {
          updatedGoal.completedAt = null;
        }
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour le statut: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Logic to update goal progress based on transactions
  void _updateGoalProgress() {
    for (var goal in financialGoals) {
      if (goal.status == GoalStatus.active) {
        double newCurrentAmount = 0.0;

        // For savings/purchase goals, rely on linkedCategoryId
        if (goal.type == GoalType.savings ||
            goal.type == GoalType.purchase ||
            goal.type == GoalType.custom) {
          if (goal.linkedCategoryId != null) {
            newCurrentAmount = _financialContextService.allTransactions
                .where((tx) =>
                    tx.categoryId == goal.linkedCategoryId &&
                    tx.date.isAfter(goal.createdAt))
                .fold(
                    0.0,
                    (sum, tx) =>
                        sum +
                        tx.amount
                            .abs()); // Count both income and expense contributions
          }
        }
        // For debt payoff goals, sum specific debt repayment transactions
        else if (goal.type == GoalType.debtPayoff &&
            goal.linkedDebtId != null) {
          // Verify the debt still exists
          final debt = _financialContextService.allDebts
              .firstWhereOrNull((d) => d.id == goal.linkedDebtId);
          if (debt != null) {
            newCurrentAmount = _financialContextService.allTransactions
                .where((tx) =>
                    tx.type == TransactionType.expense &&
                    tx.linkedDebtId == goal.linkedDebtId &&
                    tx.date.isAfter(goal.createdAt))
                .fold(0.0, (sum, tx) => sum + tx.amount);
          }
        }

        // Only update if amount changed to avoid infinite loops or unnecessary writes
        if ((newCurrentAmount - goal.currentAmount).abs() > 0.01) {
          final oldProgress = goal.progressPercentage;
          final updatedGoal = goal.copyWith(currentAmount: newCurrentAmount);
          final newProgress = updatedGoal.progressPercentage;

          // Check for completion
          if (updatedGoal.currentAmount >= updatedGoal.targetAmount &&
              goal.status != GoalStatus.completed) {
            updatedGoal.status = GoalStatus.completed;
            updatedGoal.completedAt = DateTime.now();
            _financialEventsService
                .emit(GoalEvent(FinancialEventType.goalCompleted, updatedGoal));
          } else {
            // Check for milestones (e.g., every 25%)
            if ((newProgress / 25).floor() > (oldProgress / 25).floor()) {
              _financialEventsService.emit(GoalEvent(
                  FinancialEventType.goalMilestoneReached, updatedGoal));
            }
          }

          IsarService.updateGoal(updatedGoal);
          // Note: Watcher will update the list
        }
      }
    }
  }

  // Calculate estimated completion date (simplified)
  DateTime? estimateCompletionDate(FinancialGoal goal) {
    if (goal.targetAmount <= goal.currentAmount) return DateTime.now();

    final remainingAmount = goal.targetAmount - goal.currentAmount;
    // Assuming monthly savings. This needs to be more sophisticated, considering
    // average monthly savings or user-defined monthly contribution.
    final monthlyContribution = _financialContextService
        .averageMonthlySavings.value; // Example, need to implement this getter

    if (monthlyContribution <= 0) return null; // No progress, cannot estimate

    final monthsToComplete = remainingAmount / monthlyContribution;
    return DateTime.now().add(Duration(days: (monthsToComplete * 30).round()));
  }

  // Method to get a specific goal by ID
  Future<FinancialGoal?> getGoalById(String goalId) async {
    return IsarService.getGoalById(goalId);
  }

  // Clear all goals (for testing/reset)
  Future<void> clearAllGoals() async {
    IsarService.clearGoals();
    financialGoals.clear();
  }
}
