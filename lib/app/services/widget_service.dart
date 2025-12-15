import 'package:home_widget/home_widget.dart';
import 'package:get/get.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/modules/challenges/controllers/challenges_controller.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart';
import 'package:intl/intl.dart';

/// Service to update home screen widgets with latest financial data
class WidgetService {
  static const String appGroupId = 'group.com.koala.widgets';
  static const String androidWidgetName = 'KoalaWidgetProvider';

  static final _currencyFormat = NumberFormat.compact(locale: 'fr_FR');

  /// Initialize widget service
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  /// Update all widgets with current data
  static Future<void> updateAllWidgets() async {
    await _updateBalanceWidget();
    await _updateTodaySpendingWidget();
    await _updateWeeklySpendingWidget();
    await _updateBudgetWidget();
    await _updateStreakWidget();
    await _updateGoalWidget();

    // Trigger widget refresh
    await HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: 'KoalaWidget',
    );
  }

  /// Update balance widget data
  static Future<void> _updateBalanceWidget() async {
    try {
      final context = Get.find<FinancialContextService>();
      final balance = context.currentBalance;
      final formatted = _currencyFormat.format(balance.abs());
      final sign = balance >= 0 ? '' : '-';

      await HomeWidget.saveWidgetData('balance', '$sign$formatted F');
      await HomeWidget.saveWidgetData('balance_raw', balance.toString());
      await HomeWidget.saveWidgetData(
          'balance_positive', (balance >= 0).toString());
    } catch (_) {}
  }

  /// Update today's spending widget
  static Future<void> _updateTodaySpendingWidget() async {
    try {
      final context = Get.find<FinancialContextService>();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final todaySpending = context.allTransactions
          .where((t) =>
              t.type.name == 'expense' &&
              t.date.isAfter(todayStart.subtract(const Duration(seconds: 1))))
          .fold(0.0, (sum, t) => sum + t.amount);

      await HomeWidget.saveWidgetData(
          'today_spending', _currencyFormat.format(todaySpending));
    } catch (_) {}
  }

  /// Update weekly spending chart data
  static Future<void> _updateWeeklySpendingWidget() async {
    try {
      final context = Get.find<FinancialContextService>();
      final now = DateTime.now();

      final List<double> weekData = [];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final daySpending = context.allTransactions
            .where((t) =>
                t.type.name == 'expense' &&
                t.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(dayEnd))
            .fold(0.0, (sum, t) => sum + t.amount);

        weekData.add(daySpending);
      }

      // Store as comma-separated values
      await HomeWidget.saveWidgetData('weekly_data', weekData.join(','));

      // Calculate week total
      final weekTotal = weekData.fold(0.0, (a, b) => a + b);
      await HomeWidget.saveWidgetData(
          'week_total', _currencyFormat.format(weekTotal));
    } catch (_) {}
  }

  /// Update budget progress widget
  static Future<void> _updateBudgetWidget() async {
    try {
      final context = Get.find<FinancialContextService>();
      final now = DateTime.now();

      if (context.allBudgets.isNotEmpty) {
        final budget = context.allBudgets.first;
        final spent = context.getSpentAmountForCategory(
          budget.categoryId ?? '',
          now.year,
          now.month,
        );
        final progress = (spent / budget.amount).clamp(0.0, 1.0);
        final remaining = (budget.amount - spent).clamp(0.0, double.infinity);

        await HomeWidget.saveWidgetData(
            'budget_name', budget.categoryId ?? 'Budget');
        await HomeWidget.saveWidgetData('budget_progress', progress.toString());
        await HomeWidget.saveWidgetData(
            'budget_remaining', _currencyFormat.format(remaining));
        await HomeWidget.saveWidgetData('budget_has_data', 'true');
      } else {
        await HomeWidget.saveWidgetData('budget_has_data', 'false');
      }
    } catch (_) {}
  }

  /// Update streak widget
  static Future<void> _updateStreakWidget() async {
    try {
      if (Get.isRegistered<ChallengesController>()) {
        final controller = Get.find<ChallengesController>();
        await HomeWidget.saveWidgetData(
            'streak', controller.currentStreak.value.toString());
      } else {
        await HomeWidget.saveWidgetData('streak', '0');
      }
    } catch (_) {}
  }

  /// Update goal progress widget
  static Future<void> _updateGoalWidget() async {
    try {
      if (Get.isRegistered<GoalsController>()) {
        final controller = Get.find<GoalsController>();

        if (controller.activeGoals.isNotEmpty) {
          final goal = controller.activeGoals.first;
          final progress = goal.progressPercentage / 100.0;

          await HomeWidget.saveWidgetData('goal_title', goal.title);
          await HomeWidget.saveWidgetData('goal_progress', progress.toString());
          await HomeWidget.saveWidgetData(
              'goal_current', _currencyFormat.format(goal.currentAmount));
          await HomeWidget.saveWidgetData(
              'goal_target', _currencyFormat.format(goal.targetAmount));
          await HomeWidget.saveWidgetData('goal_has_data', 'true');
        } else {
          await HomeWidget.saveWidgetData('goal_has_data', 'false');
        }
      }
    } catch (_) {}
  }

  /// Called when widget is clicked
  static Future<void> handleWidgetClick(Uri? uri) async {
    if (uri == null) return;

    switch (uri.host) {
      case 'add_expense':
        // Navigate to add expense
        break;
      case 'add_income':
        // Navigate to add income
        break;
      case 'open_app':
      default:
        // Just open app
        break;
    }
  }
}
