// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // New Import
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/financial_goal.dart'; // New Import
import 'package:koaa/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:koaa/app/modules/goals/controllers/goals_controller.dart'; 
import 'package:koaa/app/modules/goals/views/widgets/goal_card.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> with SingleTickerProviderStateMixin {
  final AnalyticsController controller = Get.find<AnalyticsController>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs: Overview, Budgets, Goals, Debts
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text(
          'Analyse Financière',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.add_circled_solid, color: theme.iconTheme.color),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddJobDialog(context, theme); // Keep existing add job dialog
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomTabBar(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to force tab usage
                children: [
                  // Overview Tab
                  _buildOverviewTab(theme),
                  // Budgets Tab
                  _buildBudgetsTab(theme),
                  // Goals Tab
                  _buildGoalsTab(theme),
                  // Debts Tab
                  _buildDebtsTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(ThemeData theme) {
    final tabs = ['Vue d\'ensemble', 'Budgets', 'Objectifs', 'Dettes'];
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              setState(() {}); // Rebuild to update selected state
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _tabController.index == index
                    ? theme.primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: _tabController.index == index
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: _tabController.index == index ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          _buildTimeRangeSelector(theme),
          SizedBox(height: 16.h),
          Obx(() => controller.canNavigate
              ? _buildMonthNavigator(theme)
              : const SizedBox.shrink()),
          if (controller.canNavigate) SizedBox(height: 24.h),
          Obx(() => _buildMonthlySummary(theme)),
          SizedBox(height: 20.h),
          Obx(() => _buildJobsSection(theme)),
          SizedBox(height: 20.h),
          Obx(() => _buildCategoryCard(theme)),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          Obx(() => controller.selectedTimeRange.value == TimeRange.month
              ? _buildBudgetComparisonCard(theme)
              : _buildEmptyCard(theme, 'Sélectionnez le mois pour la comparaison budgétaire')),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildGoalsTab(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final activeGoalsData = controller.goalProgress;

      if (activeGoalsData.isEmpty) {
        return _buildEmptyCard(theme, 'Aucun objectif à afficher pour cette période.');
      }

      final double totalTargetAmount = activeGoalsData.fold(0.0, (sum, goal) => sum + goal.targetAmount);
      final double totalCurrentAmount = activeGoalsData.fold(0.0, (sum, goal) => sum + goal.currentAmount);

      final List<PieChartSectionData> pieChartSections = activeGoalsData.map((goalData) {
        final percentage = (goalData.currentAmount / (goalData.targetAmount == 0 ? 1 : goalData.targetAmount) * 100).clamp(0.0, 100.0);
        return PieChartSectionData(
          color: Color(goalData.colorValue),
          value: goalData.currentAmount,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50.r,
          titleStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progression des Objectifs',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                ),
              ),
              child: Column(
                children: [
                  if (totalCurrentAmount > 0)
                    SizedBox(
                      height: 200.h,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40.r,
                          sections: pieChartSections,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                        height: 100.h,
                        child: Center(
                            child: Text("Aucune progression",
                                style: TextStyle(color: Colors.grey)))),
                  SizedBox(height: 24.h),
                  ...activeGoalsData.map((goalData) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: Color(goalData.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              goalData.title,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color),
                            ),
                          ],
                        ),
                        Text(
                          '${goalData.progressPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Détails',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeGoalsData.length,
              itemBuilder: (context, index) {
                final data = activeGoalsData[index];
                // Map to FinancialGoal to reuse GoalCard
                // Using a dummy financial goal object just for display
                final goal = FinancialGoal(
                    id: data.id,
                    title: data.title,
                    targetAmount: data.targetAmount,
                    currentAmount: data.currentAmount,
                    colorValue: data.colorValue,
                    targetDate: data.targetDate,
                    status: GoalStatus.active, 
                    type: GoalType.savings, 
                );
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: GoalCard(goal: goal),
                );
              },
            ),
            SizedBox(height: 32.h),
          ],
        ),
      );
    });
  }

  Widget _buildDebtsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          Obx(() => controller.selectedTimeRange.value != TimeRange.month && controller.debtTimeline.isNotEmpty
              ? _buildDebtTimelineCard(theme)
              : _buildEmptyCard(theme, 'Sélectionnez l\'année ou tout pour la chronologie de la dette')),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Obx(() => CupertinoSlidingSegmentedControl<TimeRange>(
        groupValue: controller.selectedTimeRange.value,
        children: {
          TimeRange.month: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text('Mois', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ),
          TimeRange.year: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text('Année', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ),
          TimeRange.all: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text('Tout', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp)),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            HapticFeedback.lightImpact();
            controller.setTimeRange(value);
          }
        },
        thumbColor: Colors.white,
        backgroundColor: Colors.grey.shade100,
      )),
    );
  }

  Widget _buildMonthNavigator(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => IconButton(
            icon: Icon(CupertinoIcons.chevron_left, size: 20.sp),
            onPressed: controller.canNavigate ? () {
              HapticFeedback.lightImpact();
              controller.navigatePrevious();
            } : null,
            color: controller.canNavigate ? theme.iconTheme.color : theme.disabledColor,
          )),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // Removed controller.navigateToCurrentMonth(); as it's no longer needed
            },
            child: Column(
              children: [
                Obx(() => Text(
                  controller.currentPeriodName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                )),
              ],
            ),
          ),
          Obx(() => IconButton(
            icon: Icon(CupertinoIcons.chevron_right, size: 20.sp),
            onPressed: controller.canNavigate ? () {
              HapticFeedback.lightImpact();
              controller.navigateNext();
            } : null,
            color: controller.canNavigate ? theme.iconTheme.color : theme.disabledColor,
          )),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Solde Net',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.money_dollar_circle,
                    color: isDark ? Colors.white70 : Colors.grey.shade400,
                    size: 20.sp,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'FCFA ${_formatAmount(controller.netBalance)}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF2D3250),
                  letterSpacing: -1,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: (controller.netBalance >= 0 ? Colors.green : Colors.orange).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.netBalance >= 0
                          ? 'Épargne positive ✨'
                          : 'Attention au budget ⚠️',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: controller.netBalance >= 0 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (controller.selectedTimeRange.value != TimeRange.all) ...[
                    SizedBox(width: 8.w),
                    _buildTrendBadge(),
                  ]
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Revenus',
                controller.totalIncome,
                CupertinoIcons.arrow_down_left_circle_fill,
                Colors.green,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSummaryCard(
                theme,
                'Dépenses',
                controller.totalExpenses,
                CupertinoIcons.arrow_up_right_circle_fill,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTrendBadge() {
    final trend = controller.expenseTrendPercentage;
    if (trend == 0) return const SizedBox.shrink();
    
    final isUp = trend > 0;
    final color = isUp ? Colors.red : Colors.green;
    final icon = isUp ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 2.w),
          Text(
            '${trend.abs().toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2D3250),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }



  Widget _buildJobsSection(ThemeData theme) {
    final jobs = controller.jobs;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes Emplois', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
              Text(
                '${jobs.length}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (jobs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Aucun revenu ajouté',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ...jobs.map((job) => _buildJobTile(theme, job)),
        ],
      ),
    );
  }

  Widget _buildJobTile(ThemeData theme, Job job) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(CupertinoIcons.briefcase_fill, color: isDark ? Colors.white : Colors.black, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                ),
                Text(
                  '${job.frequency.displayName}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '${_formatAmount(job.monthlyIncome)}',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.green.shade700),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _showJobOptions(Get.context!, theme, job),
            child: Icon(Icons.more_vert, size: 18.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ThemeData theme) {
    final chartData = controller.chartData;
    if (chartData.isEmpty) {
      return _buildEmptyCard(theme, 'Aucune dépense sur cette période');
    }

    final total = chartData.fold(0.0, (sum, e) => sum + e.value);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dépenses par catégorie', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
          SizedBox(height: 24.h),
          
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40.r,
                sections: chartData.map((data) {
                  final percentage = (data.value / total * 100).toStringAsFixed(0);
                  return PieChartSectionData(
                    color: Color(data.colorValue),
                    value: data.value,
                    title: '$percentage%',
                    radius: 50.r,
                    titleStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          SizedBox(height: 24.h),
          
          ...chartData.map((data) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Color(data.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        data.name,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                  Text(
                    'FCFA ${_formatAmount(data.value)}',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(ThemeData theme, String message) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetComparisonCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final budgetComparisons = controller.budgetComparison;

    if (budgetComparisons.isEmpty) {
      return _buildEmptyCard(theme, 'Aucun budget défini pour cette période');
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparaison Budgétaire',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2D3250),
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: budgetComparisons.length,
            itemBuilder: (context, index) {
              final data = budgetComparisons[index];
              final actualPercentageSpent = data.spentAmount / (data.budgetedAmount == 0 ? 1 : data.budgetedAmount);
              final percentageSpent = actualPercentageSpent.clamp(0.0, 1.0);
              final remaining = data.budgetedAmount - data.spentAmount;
              final isOverBudget = data.spentAmount > data.budgetedAmount;
              final overageAmount = isOverBudget ? data.spentAmount - data.budgetedAmount : 0.0;

              Color progressColor = Color(data.colorValue);
              String statusText = '';
              if (actualPercentageSpent > 1.0) {
                progressColor = Colors.red;
                statusText = 'Dépassement';
              } else if (actualPercentageSpent >= 0.8) {
                progressColor = Colors.orange;
                statusText = 'Proche de la limite';
              } else {
                statusText = 'En cours';
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.categoryName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          '${(actualPercentageSpent * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Main progress bar
                    LinearProgressIndicator(
                      value: percentageSpent,
                      backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 8.h,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    // Overage indicator if over budget
                    if (isOverBudget) ...[
                      SizedBox(height: 6.h),
                      Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 4.h,
                            width: (overageAmount / data.budgetedAmount * 100).clamp(0.0, double.infinity) / 100 * 100,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget: FCFA ${_formatAmount(data.budgetedAmount)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? Colors.white60 : Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          remaining >= 0
                              ? 'Reste: FCFA ${_formatAmount(remaining)}'
                              : 'Dépassement: FCFA ${_formatAmount(remaining.abs())}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: remaining < 0 ? FontWeight.w600 : FontWeight.normal,
                            color: remaining < 0 ? Colors.red : (isDark ? Colors.white60 : Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDebtTimelineCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final debtTimeline = controller.debtTimeline;

    if (debtTimeline.isEmpty) {
      return _buildEmptyCard(theme, 'Aucune donnée de dette pour cette période');
    }

    // Sort timeline data by date to ensure correct chart display
    debtTimeline.sort((a, b) => a.date.compareTo(b.date));

    // Prepare data for the LineChart
    final List<FlSpot> spots = debtTimeline.asMap().entries.map((entry) {
      // Use index as x-value for linear progression, date for labels
      return FlSpot(entry.key.toDouble(), entry.value.totalOutstanding);
    }).toList();

    // Find min and max Y values for the chart
    double minY = 0;
    double maxY = 100;

    if (spots.isNotEmpty) {
      minY = spots.map((spot) => spot.y).reduce(min);
      maxY = spots.map((spot) => spot.y).reduce(max);
      minY = (minY * 0.9).floorToDouble(); // 10% buffer below min
      maxY = (maxY * 1.1).ceilToDouble(); // 10% buffer above max
    }


    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression de la Dette',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF2D3250),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dette Totale Actuelle',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
              Text(
                'FCFA ${_formatAmount(controller.debtTimeline.last.totalOutstanding)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paiements effectués ce mois',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.grey.shade800,
                ),
              ),
              Text(
                'FCFA ${_formatAmount(controller.debtTimeline.last.paymentsMade)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Display month/year for labels
                        if (value.toInt() < debtTimeline.length) {
                          final date = debtTimeline[value.toInt()].date;
                          return Padding( // Use Padding instead of SideTitleWidget
                            padding: const EdgeInsets.only(top: 8.0), // Approximate spacing
                            child: Text(
                              controller.selectedTimeRange.value == TimeRange.year || controller.selectedTimeRange.value == TimeRange.all
                                ? DateFormat('MMM').format(date) // Show month for year/all view
                                : DateFormat('dd').format(date), // Show day for month view
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                                fontSize: 10.sp,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: (debtTimeline.length / 5).ceilToDouble(), // Adjust interval for readability
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding( // Use Padding instead of SideTitleWidget
                          padding: const EdgeInsets.only(right: 8.0), // Approximate spacing
                          child: Text(
                            NumberFormat.compact().format(value),
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey.shade600,
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      },
                      interval: (maxY - minY) / 4, // 4 intervals
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.red.shade900],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent.withOpacity(0.3),
                          Colors.red.shade900.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: minY,
                maxY: maxY,
                // maxX should be spots.length - 1
                maxX: (debtTimeline.length - 1).toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,###', 'fr_FR').format(amount.round());
  }

  // Dialogs implementation
  void _showAddJobDialog(BuildContext context, ThemeData theme) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final selectedFrequency = PaymentFrequency.monthly.obs;
    final paymentDate = DateTime.now().obs;

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Ajouter un emploi',
        icon: CupertinoIcons.briefcase,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KoalaTextField(
                  controller: nameController,
                  label: 'Nom du job',
                  icon: CupertinoIcons.tag,
                ),
                SizedBox(height: 16.h),
                KoalaTextField(
                  controller: amountController,
                  label: 'Montant',
                  icon: CupertinoIcons.money_dollar,
                  keyboardType: TextInputType.number,
                  isAmount: true,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Fréquence',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: DropdownButton<PaymentFrequency>(
                    value: selectedFrequency.value,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: theme.cardColor,
                    items: PaymentFrequency.values.map((freq) => DropdownMenuItem(
                      value: freq,
                      child: Text(freq.displayName),
                    )).toList(),
                    onChanged: (value) { if (value != null) selectedFrequency.value = value; },
                  ),
                )),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: KoalaButton(
                        text: 'Annuler',
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        textColor: Colors.grey,
                        onPressed: () => NavigationHelper.safeBack(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: KoalaButton(
                        text: 'Ajouter',
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le nom du job est requis', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          if (amountController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le montant est requis', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            Get.snackbar('Erreur', 'Le montant doit être > 0', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          await controller.addJob(
                            name: nameController.text.trim(),
                            amount: amount,
                            frequency: selectedFrequency.value,
                            paymentDate: paymentDate.value,
                          );
                          NavigationHelper.safeBack();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h), // Safe area padding
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
  

  
  void _showJobOptions(BuildContext context, ThemeData theme, Job job) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: job.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.pencil, color: Colors.blue),
              title: const Text('Modifier'),
              onTap: () { 
                NavigationHelper.safeBack(); 
                _showEditJobDialog(context, theme, job); 
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.trash, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () { 
                NavigationHelper.safeBack(); 
                KoalaConfirmationDialog.show(
                  context: context,
                  title: 'Supprimer l\'emploi',
                  message: 'Êtes-vous sûr de vouloir supprimer "${job.name}" ?',
                  isDestructive: true,
                  onConfirm: () async {
                    await controller.deleteJob(job.id);
                  },
                );
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
  
  void _showEditJobDialog(BuildContext context, ThemeData theme, Job job) {
    final nameController = TextEditingController(text: job.name);
    final amountController = TextEditingController(text: job.amount.toString());
    final selectedFrequency = job.frequency.obs;
    final paymentDate = job.paymentDate.obs;

    Get.bottomSheet(
      KoalaBottomSheet(
        title: 'Modifier un emploi',
        icon: CupertinoIcons.pencil,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KoalaTextField(
                  controller: nameController,
                  label: 'Nom du job',
                  icon: CupertinoIcons.tag,
                ),
                SizedBox(height: 16.h),
                KoalaTextField(
                  controller: amountController,
                  label: 'Montant',
                  icon: CupertinoIcons.money_dollar,
                  keyboardType: TextInputType.number,
                  isAmount: true,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Fréquence',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: DropdownButton<PaymentFrequency>(
                    value: selectedFrequency.value,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    dropdownColor: theme.cardColor,
                    items: PaymentFrequency.values.map((freq) => DropdownMenuItem(
                      value: freq,
                      child: Text(freq.displayName),
                    )).toList(),
                    onChanged: (value) { if (value != null) selectedFrequency.value = value; },
                  ),
                )),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: KoalaButton(
                        text: 'Annuler',
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        textColor: Colors.grey,
                        onPressed: () => NavigationHelper.safeBack(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: KoalaButton(
                        text: 'Enregistrer',
                        backgroundColor: Colors.orange,
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le nom du job est requis', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          if (amountController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le montant est requis', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            Get.snackbar('Erreur', 'Le montant doit être > 0', snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          final updated = job.copyWith(
                            name: nameController.text.trim(),
                            amount: amount,
                            frequency: selectedFrequency.value,
                            paymentDate: paymentDate.value,
                          );
                          await controller.updateJob(updated);
                          NavigationHelper.safeBack();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}