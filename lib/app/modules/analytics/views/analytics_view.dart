// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:koaa/app/services/ml_service.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          children:
              [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Analytics', style: theme.textTheme.titleLarge),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.info_circle,
                              size: 28,
                            ),
                            onPressed: () {},
                            splashRadius: 24,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Period selector
                    Obx(() => _buildPeriodSelector()),

                    const SizedBox(height: 24),

                    // Main balance card
                    Obx(() => _buildBalanceCard(theme)),

                    const SizedBox(height: 16),

                    // Income/Expense row
                    Obx(
                      () => Row(
                        children: [
                          Expanded(child: _buildSummaryCard(theme, true)),
                          SizedBox(width: 12.w),
                          Expanded(child: _buildSummaryCard(theme, false)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Spending trend
                    Obx(() => _buildSpendingTrendCard(theme)),

                    const SizedBox(height: 24),

                    // Category breakdown
                    Obx(() => _buildCategoryCard(theme)),

                    const SizedBox(height: 24),

                    // Insights
                    Obx(() => _buildInsightsCard(theme)),

                    const SizedBox(height: 24),

                    // ML Insights Section
                    Obx(
                      () => controller.mlInsights.isNotEmpty
                          ? Column(
                              children: [
                                _buildMLInsightsCard(theme),
                                const SizedBox(height: 24),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Spending Pattern
                    Obx(
                      () => controller.spendingPattern.value != null
                          ? Column(
                              children: [
                                _buildSpendingPatternCard(theme),
                                const SizedBox(height: 24),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ]
                  .animate(interval: 50.ms)
                  .slideY(
                    begin: 0.1,
                    duration: 300.ms,
                    curve: Curves.easeOutQuart,
                  )
                  .fadeIn(duration: 200.ms),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          _buildPeriodChip('Semaine'),
          SizedBox(width: 12.w),
          _buildPeriodChip('Mois'),
          SizedBox(width: 12.w),
          _buildPeriodChip('Année'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = controller.selectedPeriod.value == period;
    return GestureDetector(
      onTap: () => controller.selectedPeriod.value = period,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1B1E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1B1E) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    final balance = controller.netBalance;
    final savingsRate = controller.savingsRate;
    final isPositive = balance >= 0;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1B1E),
            const Color(0xFF1A1B1E).withAlpha((0.95 * 255).round()),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? CupertinoIcons.arrow_up
                          : CupertinoIcons.arrow_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'FCFA ${_formatAmount(balance.abs())}',
            style: TextStyle(
              fontSize: 42.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isPositive ? 'You\'re doing great!' : 'Budget exceeded',
            style: TextStyle(fontSize: 14.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, bool isIncome) {
    final amount = isIncome ? controller.totalIncome : controller.totalExpenses;
    final label = isIncome ? 'Income' : 'Expense';
    final icon = isIncome ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up;
    final color = isIncome
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: color.withAlpha(25),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'FCFA ${_formatAmount(amount)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendCard(ThemeData theme) {
    final trendData = controller.dailySpendingTrend;
    if (trendData.isEmpty) {
      return _buildEmptyCard(theme, 'No spending data available');
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Trend', style: theme.textTheme.titleMedium),
              if (controller.percentageChange != 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: controller.percentageChange > 0
                        ? Colors.red.withAlpha(25)
                        : Colors.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.percentageChange > 0
                            ? CupertinoIcons.arrow_up
                            : CupertinoIcons.arrow_down,
                        size: 12.sp,
                        color: controller.percentageChange > 0
                            ? Colors.red
                            : Colors.green,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${controller.percentageChange.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: controller.percentageChange > 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          // Wrap chart in RepaintBoundary to isolate repaints
          RepaintBoundary(
            child: SizedBox(
              height: 180.h,
              child: _SpendingTrendChart(
                trendData: trendData,
                primaryColor: theme.colorScheme.primary,
                surfaceColor: theme.colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ThemeData theme) {
    final categories = controller.topSpendingCategories;
    if (categories.isEmpty) {
      return _buildEmptyCard(theme, 'No expense data available');
    }

    final total = categories.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Categories', style: theme.textTheme.titleMedium),
          SizedBox(height: 16.h),
          ...categories.map((entry) {
            final percentage = (entry.value / total) * 100;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'FCFA ${_formatAmount(entry.value)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 6.h,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(ThemeData theme) {
    final avgDaily = controller.averageDailySpending;
    final predicted = controller.predictedBalance;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Insights', style: theme.textTheme.titleMedium),
          SizedBox(height: 16.h),
          _buildInsightRow(
            theme,
            'Daily Average',
            'FCFA ${_formatAmount(avgDaily)}',
            CupertinoIcons.calendar,
          ),
          SizedBox(height: 12.h),
          _buildInsightRow(
            theme,
            'End of Month',
            'FCFA ${_formatAmount(predicted)}',
            CupertinoIcons.clock,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.grey.shade700, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  String _formatCompactAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildMLInsightsCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb_fill,
                color: Colors.amber,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text('ML Insights', style: theme.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 16.h),
          ...controller.mlInsights.map((insight) {
            Color iconColor;
            IconData iconData;

            switch (insight.type) {
              case InsightType.positive:
                iconColor = Colors.green;
                iconData = CupertinoIcons.checkmark_circle_fill;
                break;
              case InsightType.warning:
                iconColor = Colors.orange;
                iconData = CupertinoIcons.exclamationmark_triangle_fill;
                break;
              case InsightType.tip:
                iconColor = Colors.blue;
                iconData = CupertinoIcons.lightbulb_fill;
                break;
              case InsightType.info:
              default:
                iconColor = Colors.grey.shade600;
                iconData = CupertinoIcons.info_circle_fill;
                break;
            }

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(iconData, color: iconColor, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          insight.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpendingPatternCard(ThemeData theme) {
    final pattern = controller.spendingPattern.value;
    if (pattern == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.graph_circle_fill,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text('Spending Pattern', style: theme.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 16.h),
          _buildPatternRow(
            theme,
            'Trend',
            pattern.trend == SpendingTrend.increasing
                ? '📈 Increasing'
                : pattern.trend == SpendingTrend.decreasing
                ? '📉 Decreasing'
                : '➡️ Stable',
          ),
          SizedBox(height: 8.h),
          _buildPatternRow(
            theme,
            'Consistency Score',
            '${pattern.consistencyScore}%',
          ),
          SizedBox(height: 8.h),
          _buildPatternRow(
            theme,
            'Top Category',
            '${pattern.topCategory.icon} ${pattern.topCategory.displayName}',
          ),
          SizedBox(height: 8.h),
          _buildPatternRow(theme, 'Peak Day', _getDayName(pattern.peakDay)),
        ],
      ),
    );
  }

  Widget _buildPatternRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Unknown';
    }
  }
}

class _SpendingTrendChart extends StatelessWidget {
  final Map<DateTime, double> trendData;
  final Color primaryColor;
  final Color surfaceColor;

  const _SpendingTrendChart({
    required this.trendData,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCompactAmount(value),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= trendData.length) {
                  return const SizedBox.shrink();
                }
                final date = trendData.keys.elementAt(index);
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    DateFormat('EEE').format(date).substring(0, 1),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trendData.entries
                .toList()
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                .toList(),
            isCurved: true,
            color: primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: surfaceColor,
                  strokeWidth: 2,
                  strokeColor: primaryColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withAlpha(25),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1A1B1E),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'FCFA ${_formatAmount(spot.y)}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  String _formatCompactAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
