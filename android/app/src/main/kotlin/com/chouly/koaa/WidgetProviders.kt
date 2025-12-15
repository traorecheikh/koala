package com.chouly.koaa

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class BalanceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_balance).apply {
                val balance = widgetData.getString("balance", "0 F") ?: "0 F"
                setTextViewText(R.id.balance_value, balance)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class QuickAddWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_today).apply {
                val todaySpending = widgetData.getString("today_spending", "0") ?: "0"
                setTextViewText(R.id.today_spending, "$todaySpending F")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class StreakWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_streak).apply {
                val streak = widgetData.getString("streak", "0") ?: "0"
                setTextViewText(R.id.streak_value, streak)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class WeeklyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_weekly).apply {
                val weekTotal = widgetData.getString("week_total", "0") ?: "0"
                setTextViewText(R.id.week_total, "$weekTotal F")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class BudgetWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_budget).apply {
                val budgetName = widgetData.getString("budget_name", "Budget") ?: "Budget"
                val remaining = widgetData.getString("budget_remaining", "0") ?: "0"
                setTextViewText(R.id.budget_name, budgetName)
                setTextViewText(R.id.budget_remaining, "$remaining restant")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class GoalWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_goal).apply {
                val goalTitle = widgetData.getString("goal_title", "Objectif") ?: "Objectif"
                val current = widgetData.getString("goal_current", "0") ?: "0"
                val target = widgetData.getString("goal_target", "0") ?: "0"
                val progress = widgetData.getString("goal_progress", "0")?.toFloatOrNull() ?: 0f
                val percent = (progress * 100).toInt()
                
                setTextViewText(R.id.goal_title, goalTitle)
                setTextViewText(R.id.goal_current, current)
                setTextViewText(R.id.goal_target, target)
                setTextViewText(R.id.goal_percent, "$percent%")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

