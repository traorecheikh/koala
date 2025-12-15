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
