package com.chouly.koaa

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File


class BalanceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_balance)
            val balance = widgetData.getString("balance", "0 FCFA") ?: "0 FCFA"
            
            // Time of Day Logic
            val hour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)
            
            // Gradient Background
            val backgroundRes = when {
                hour < 12 -> R.drawable.bg_balance_morning
                hour < 17 -> R.drawable.bg_balance_afternoon
                hour < 21 -> R.drawable.bg_balance_evening
                else -> R.drawable.bg_balance_night
            }
            views.setInt(R.id.widget_root, "setBackgroundResource", backgroundRes)

            // Greeting Text & Icon
            val (greeting, icon) = when {
                hour in 5..11 -> "Bonjour" to "☀️"
                hour in 12..16 -> "Bon après-midi" to "☀️"
                hour in 17..20 -> "Bonsoir" to "🌤️"
                else -> "Bonne nuit" to "🌙"
            }

            // Bind Data
            views.setTextViewText(R.id.label_solde, "Votre solde")
            views.setTextViewText(R.id.balance_value, balance)
            views.setTextViewText(R.id.greeting_text, greeting)
            views.setTextViewText(R.id.time_icon, icon)

            val intent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = Uri.parse("koala://open_app")
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            
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
            val views = RemoteViews(context.packageName, R.layout.widget_quick_add).apply {
                // Actions handle click directly on buttons
                val expenseIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("koala://add_expense")
                }
                val expensePendingIntent = PendingIntent.getActivity(
                    context,
                    1,
                    expenseIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.btn_expense, expensePendingIntent)

                val incomeIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("koala://add_income")
                }
                val incomePendingIntent = PendingIntent.getActivity(
                    context,
                    2,
                    incomeIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.btn_income, incomePendingIntent)
            }
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
                val todaySpending = widgetData.getString("today_spending", "0 F") ?: "0 F"
                setTextViewText(R.id.value_today, todaySpending)

                val intent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW
                    data = Uri.parse("koala://open_app")
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    3,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.value_today, pendingIntent) // Clickable value
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
                setTextViewText(R.id.budget_name, budgetName)
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
                setTextViewText(R.id.goal_title, goalTitle)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

