// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/data/models/job.dart';
import 'package:koaa/app/data/models/financial_goal.dart';
import 'package:koaa/app/modules/analytics/controllers/analytics_controller.dart';
import 'package:koaa/app/modules/goals/views/widgets/goal_card.dart';

import 'package:koaa/app/modules/analytics/widgets/spending_heatmap.dart'; // New import

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final AnalyticsController controller = Get.find<AnalyticsController>();

// ... (rest of imports)

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: KoalaColors.background(context),
        appBar: AppBar(
          backgroundColor: KoalaColors.surface(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Analytique',
            style: KoalaTypography.heading3(context),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.h),
            child: Container(
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                border: Border(
                  bottom: BorderSide(
                    color: KoalaColors.border(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: TabBar(
                labelColor: KoalaColors.accent,
                unselectedLabelColor: KoalaColors.textSecondary(context),
                labelStyle: KoalaTypography.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: KoalaTypography.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w500),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: KoalaColors.accent,
                      width: 3.h,
                    ),
                  ),
                ),
                indicatorPadding: EdgeInsets.symmetric(horizontal: 20.w),
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                tabs: const [
                  Tab(text: 'Aperçu'),
                  Tab(text: 'Budgets'),
                  Tab(text: 'Objectifs'),
                  Tab(text: 'Dettes'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildBudgetsTab(context),
            _buildGoalsTab(context),
            _buildDebtsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          _buildTimeRangeSelector(context),
          SizedBox(height: KoalaSpacing.lg),
          Obx(() => controller.canNavigate
              ? _buildMonthNavigator(context)
              : const SizedBox.shrink()),
          if (controller.canNavigate) SizedBox(height: KoalaSpacing.xxl),
          Obx(() => _buildMonthlySummary(context)),
          SizedBox(height: KoalaSpacing.xl),

          // Spending Heatmap (Only in Month View)
          Obx(() {
            if (controller.selectedTimeRange.value == TimeRange.month &&
                controller.dailySpending.isNotEmpty) {
              final days = DateTime(controller.selectedYear.value,
                      controller.selectedMonth.value + 1, 0)
                  .day;
              return Padding(
                padding: EdgeInsets.only(bottom: KoalaSpacing.xl),
                child: SpendingHeatmap(
                  dailySpending: controller.dailySpending,
                  daysInMonth: days,
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          _buildMultiMonthProjectionCard(context),
          SizedBox(height: KoalaSpacing.xl),
          Obx(() => _buildJobsSection(context)),
          SizedBox(height: KoalaSpacing.xl),
          Obx(() => _buildCategoryCard(context)),
          SizedBox(height: KoalaSpacing.xxxl),
        ]
            .animate(interval: 50.ms)
            .fadeIn(duration: KoalaAnim.medium)
            .slideY(begin: 0.1, curve: KoalaAnim.entryCurve),
      ),
    );
  }

  Widget _buildMultiMonthProjectionCard(BuildContext context) {
    final projection = controller.getMultiMonthProjection();

    if (projection.months.isEmpty) {
      return const SizedBox.shrink();
    }

    final trendColor = projection.trend == 'improving'
        ? KoalaColors.success
        : projection.trend == 'declining'
            ? KoalaColors.destructive
            : KoalaColors.textSecondary(context);

    final trendIcon = projection.trend == 'improving'
        ? CupertinoIcons.arrow_up_right
        : projection.trend == 'declining'
            ? CupertinoIcons.arrow_down_right
            : CupertinoIcons.minus;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Projection 6 Mois',
                  style: KoalaTypography.heading3(context)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(trendIcon, size: 14.sp, color: trendColor),
                    SizedBox(width: 4.w),
                    Text(
                      projection.trend == 'improving'
                          ? 'En hausse'
                          : projection.trend == 'declining'
                              ? 'En baisse'
                              : 'Stable',
                      style: KoalaTypography.caption(context).copyWith(
                        color: trendColor,
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
            projection.outlook,
            style: KoalaTypography.bodyMedium(context).copyWith(
              color: KoalaColors.textSecondary(context),
            ),
          ),
          SizedBox(height: 16.h),
          // Mini bar chart of projected balances
          SizedBox(
            height: 120.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: projection.months.take(6).map((month) {
                final maxBalance = projection.months
                    .map((m) => m.projectedBalance.abs())
                    .reduce(max);
                final heightRatio = maxBalance > 0
                    ? (month.projectedBalance.abs() / maxBalance)
                        .clamp(0.1, 1.0)
                    : 0.1;
                final isNegative = month.projectedBalance < 0;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(month.projectedBalance / 1000).toStringAsFixed(0)}k',
                          style: KoalaTypography.caption(context).copyWith(
                            fontSize: 9.sp,
                            color: isNegative
                                ? KoalaColors.destructive
                                : KoalaColors.success,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          height: (80 * heightRatio).h,
                          decoration: BoxDecoration(
                            color: isNegative
                                ? KoalaColors.destructive.withValues(alpha: 0.7)
                                : KoalaColors.accent.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          month.monthName,
                          style: KoalaTypography.caption(context).copyWith(
                            fontSize: 10.sp,
                            color: KoalaColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.h),
          // Summary row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Épargne 3 mois',
                      style: KoalaTypography.caption(context).copyWith(
                        color: KoalaColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      '${_formatAmount(projection.projectedSavingsIn3Months)} FCFA',
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: projection.projectedSavingsIn3Months >= 0
                            ? KoalaColors.success
                            : KoalaColors.destructive,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Épargne 6 mois',
                      style: KoalaTypography.caption(context).copyWith(
                        color: KoalaColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      '${_formatAmount(projection.projectedSavingsIn6Months)} FCFA',
                      style: KoalaTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: projection.projectedSavingsIn6Months >= 0
                            ? KoalaColors.success
                            : KoalaColors.destructive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          Obx(() => controller.selectedTimeRange.value == TimeRange.month
              ? _buildBudgetComparisonCard(context)
              : _buildEmptyCard(
                  context,
                  'Sélectionnez le mois pour voir la comparaison budgétaire',
                  icon: CupertinoIcons.chart_bar_square,
                  actionLabel: 'Revenir au Mois',
                  onAction: () {
                    HapticFeedback.lightImpact();
                    controller.setTimeRange(TimeRange.month);
                  },
                )),
          SizedBox(height: KoalaSpacing.xxxl),
        ]
            .animate(interval: 50.ms)
            .fadeIn(duration: KoalaAnim.medium)
            .slideY(begin: 0.1, curve: KoalaAnim.entryCurve),
      ),
    );
  }

  Widget _buildGoalsTab(BuildContext context) {
    return Obx(() {
      final activeGoalsData = controller.goalProgress;

      if (activeGoalsData.isEmpty) {
        return _buildEmptyCard(
          context,
          'Créez votre premier objectif financier pour suivre vos progrès',
          icon: CupertinoIcons.flag_fill,
          actionLabel: 'Créer un Objectif',
          onAction: () {
            HapticFeedback.lightImpact();
            NavigationHelper.toNamed('/goals');
          },
        );
      }

      final totalCurrentAmount =
          activeGoalsData.fold(0.0, (sum, goal) => sum + goal.currentAmount);

      final List<PieChartSectionData> pieChartSections =
          activeGoalsData.map((goalData) {
        final percentage = (goalData.currentAmount /
                (goalData.targetAmount == 0 ? 1 : goalData.targetAmount) *
                100)
            .clamp(0.0, 100.0);
        return PieChartSectionData(
          color: Color(goalData.colorValue),
          value: goalData.currentAmount,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 50.r,
          titleStyle: KoalaTypography.caption(context).copyWith(
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
              style: KoalaTypography.heading3(context),
            ),
            SizedBox(height: KoalaSpacing.xxl),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: KoalaColors.surface(context),
                borderRadius: BorderRadius.circular(KoalaRadius.xl),
                boxShadow: KoalaColors.shadowSubtle,
                border: Border.all(color: KoalaColors.border(context)),
              ),
              child: Column(
                children: [
                  if (totalCurrentAmount > 0)
                    SizedBox(
                      height: 200.h,
                      child: RepaintBoundary(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40.r,
                            sections: pieChartSections,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                        height: 100.h,
                        child: Center(
                            child: Text("Aucune progression",
                                style: KoalaTypography.bodyMedium(context)
                                    .copyWith(
                                        color: KoalaColors.textSecondary(
                                            context))))),
                  SizedBox(height: KoalaSpacing.xxl),
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
                                  style: KoalaTypography.bodyMedium(context)
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Text(
                              '${goalData.progressPercentage.toStringAsFixed(1)}%',
                              style: KoalaTypography.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: KoalaSpacing.xl),
            Text(
              'Détails',
              style: KoalaTypography.heading3(context),
            ),
            SizedBox(height: KoalaSpacing.lg),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeGoalsData.length,
              itemBuilder: (context, index) {
                final data = activeGoalsData[index];
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
            SizedBox(height: KoalaSpacing.xxxl),
          ],
        ),
      );
    });
  }

  Widget _buildDebtsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        children: [
          Obx(() => controller.selectedTimeRange.value != TimeRange.month &&
                  controller.debtTimeline.isNotEmpty
              ? _buildDebtTimelineCard(context)
              : _buildEmptyCard(
                  context,
                  'Sélectionnez l\'année ou tout pour voir la chronologie des dettes',
                  icon: CupertinoIcons.money_dollar_circle,
                  actionLabel: 'Revenir à l\'Année',
                  onAction: () {
                    HapticFeedback.lightImpact();
                    controller.setTimeRange(TimeRange.year);
                  },
                )),
          SizedBox(height: KoalaSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: KoalaColors.inputBackground(context),
        borderRadius: BorderRadius.circular(KoalaRadius.sm),
      ),
      child: Obx(() => CupertinoSlidingSegmentedControl<TimeRange>(
            groupValue: controller.selectedTimeRange.value,
            children: {
              TimeRange.month: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Mois',
                    style: KoalaTypography.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w500)),
              ),
              TimeRange.year: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Année',
                    style: KoalaTypography.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w500)),
              ),
              TimeRange.all: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Tout',
                    style: KoalaTypography.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w500)),
              ),
            },
            onValueChanged: (value) {
              if (value != null) {
                HapticFeedback.lightImpact();
                controller.setTimeRange(value);
              }
            },
            thumbColor: KoalaColors.surface(context),
            backgroundColor: Colors.transparent,
          )),
    );
  }

  Widget _buildMonthNavigator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.md),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaColors.shadowSubtle,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => IconButton(
                icon: Icon(CupertinoIcons.chevron_left, size: 20.sp),
                onPressed: controller.canNavigate
                    ? () {
                        HapticFeedback.lightImpact();
                        controller.navigatePrevious();
                      }
                    : null,
                color: controller.canNavigate
                    ? KoalaColors.text(context)
                    : KoalaColors.textSecondary(context).withValues(alpha: 0.5),
              )),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            child: Column(
              children: [
                Obx(() => Text(
                      controller.currentPeriodName,
                      style: KoalaTypography.heading3(context),
                    )),
              ],
            ),
          ),
          Obx(() => IconButton(
                icon: Icon(CupertinoIcons.chevron_right, size: 20.sp),
                onPressed: controller.canNavigate
                    ? () {
                        HapticFeedback.lightImpact();
                        controller.navigateNext();
                      }
                    : null,
                color: controller.canNavigate
                    ? KoalaColors.text(context)
                    : KoalaColors.textSecondary(context).withValues(alpha: 0.5),
              )),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: KoalaColors.surface(context),
            borderRadius: BorderRadius.circular(KoalaRadius.xl),
            boxShadow: KoalaColors.shadowMedium,
            border: Border.all(color: KoalaColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Solde Net',
                    style: KoalaTypography.bodyMedium(context)
                        .copyWith(color: KoalaColors.textSecondary(context)),
                  ),
                  Icon(
                    CupertinoIcons.money_dollar_circle,
                    color: KoalaColors.textSecondary(context),
                    size: 20.sp,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'FCFA ${_formatAmount(controller.netBalance)}',
                style: KoalaTypography.heading1(context)
                    .copyWith(fontSize: 32.sp, letterSpacing: -1),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: (controller.netBalance >= 0
                              ? KoalaColors.success
                              : KoalaColors.warning)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.savingsStatus.label,
                      style: KoalaTypography.bodySmall(context).copyWith(
                        color: Color(controller.savingsStatus.color),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (controller.selectedTimeRange.value != TimeRange.all) ...[
                    SizedBox(width: 8.w),
                    _buildTrendBadge(context),
                  ]
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: KoalaSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                'Revenus',
                controller.totalIncome,
                CupertinoIcons.arrow_down_left_circle_fill,
                KoalaColors.success,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSummaryCard(
                context,
                'Dépenses',
                controller.totalExpenses,
                CupertinoIcons.arrow_up_right_circle_fill,
                KoalaColors.destructive,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendBadge(BuildContext context) {
    final trend = controller.expenseTrendPercentage;
    if (trend == 0) return const SizedBox.shrink();

    final isUp = trend > 0;
    final color = isUp ? KoalaColors.destructive : KoalaColors.success;
    final icon =
        isUp ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 2.w),
          Text(
            '${trend.abs().toStringAsFixed(0)}%',
            style: KoalaTypography.bodySmall(context)
                .copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: KoalaColors.border(context)),
        boxShadow: KoalaColors.shadowSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: KoalaTypography.bodySmall(context)
                .copyWith(color: KoalaColors.textSecondary(context)),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatAmount(amount),
            style: KoalaTypography.heading3(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection(BuildContext context) {
    final jobs = controller.jobs;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mes Emplois', style: KoalaTypography.heading3(context)),
              Text(
                '${jobs.length}',
                style: KoalaTypography.bodyMedium(context)
                    .copyWith(color: KoalaColors.textSecondary(context)),
              ),
            ],
          ),
          SizedBox(height: KoalaSpacing.lg),
          if (jobs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'Aucun revenu ajouté',
                  style: KoalaTypography.bodyMedium(context)
                      .copyWith(color: KoalaColors.textSecondary(context)),
                ),
              ),
            )
          else
            ...jobs.map((job) => _buildJobTile(context, job)),
        ],
      ),
    );
  }

  Widget _buildJobTile(BuildContext context, Job job) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: KoalaColors.background(context),
        borderRadius: BorderRadius.circular(KoalaRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: KoalaColors.surface(context),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(CupertinoIcons.briefcase_fill,
                color: KoalaColors.text(context), size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: KoalaTypography.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  job.frequency.displayName,
                  style: KoalaTypography.caption(context)
                      .copyWith(color: KoalaColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          Text(
            _formatAmount(job.monthlyIncome),
            style: KoalaTypography.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w700, color: KoalaColors.success),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _showJobOptions(context, job),
            child: Icon(Icons.more_vert,
                size: 18.sp, color: KoalaColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context) {
    final chartData = controller.chartData;
    if (chartData.isEmpty) {
      return _buildEmptyCard(context, 'Aucune dépense sur cette période');
    }

    final total = chartData.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dépenses par catégorie',
              style: KoalaTypography.heading3(context)),
          SizedBox(height: KoalaSpacing.xxl),
          SizedBox(
            height: 200.h,
            child: RepaintBoundary(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40.r,
                  sections: chartData.map((data) {
                    final percentage =
                        (data.value / total * 100).toStringAsFixed(0);
                    return PieChartSectionData(
                      color: Color(data.colorValue),
                      value: data.value,
                      title: '$percentage%',
                      radius: 50.r,
                      titleStyle: KoalaTypography.caption(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          SizedBox(height: KoalaSpacing.xxl),
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
                        style: KoalaTypography.bodyMedium(context)
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    'FCFA ${_formatAmount(data.value)}',
                    style: KoalaTypography.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message,
      {IconData? icon, String? actionLabel, VoidCallback? onAction}) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: KoalaColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? CupertinoIcons.chart_bar_alt_fill,
                size: 40.sp,
                color: KoalaColors.accent.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              message,
              style: KoalaTypography.bodyLarge(context).copyWith(
                color: KoalaColors.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: KoalaColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KoalaRadius.md),
                  ),
                ),
                icon: Icon(CupertinoIcons.add, size: 18.sp),
                label: Text(
                  actionLabel,
                  style: KoalaTypography.bodyMedium(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetComparisonCard(BuildContext context) {
    final budgetComparisons = controller.budgetComparison;

    if (budgetComparisons.isEmpty) {
      return _buildEmptyCard(context, 'Aucun budget défini pour cette période');
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparaison Budgétaire',
            style: KoalaTypography.heading3(context),
          ),
          SizedBox(height: KoalaSpacing.lg),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: budgetComparisons.length,
            itemBuilder: (context, index) {
              final data = budgetComparisons[index];
              final actualPercentageSpent = data.spentAmount /
                  (data.budgetedAmount == 0 ? 1 : data.budgetedAmount);
              final percentageSpent = actualPercentageSpent.clamp(0.0, 1.0);
              final remaining = data.budgetedAmount - data.spentAmount;
              final isOverBudget = data.spentAmount > data.budgetedAmount;
              final overageAmount =
                  isOverBudget ? data.spentAmount - data.budgetedAmount : 0.0;

              Color progressColor = Color(data.colorValue);
              if (actualPercentageSpent > 1.0) {
                progressColor = KoalaColors.destructive;
              } else if (actualPercentageSpent >= 0.8) {
                progressColor = KoalaColors.warning;
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
                          style: KoalaTypography.bodyMedium(context)
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${(actualPercentageSpent * 100).toStringAsFixed(0)}%',
                          style: KoalaTypography.bodyMedium(context).copyWith(
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
                      backgroundColor: KoalaColors.background(context),
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
                          color: KoalaColors.destructive.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 4.h,
                            width: (overageAmount / data.budgetedAmount * 100)
                                    .clamp(0.0, double.infinity) /
                                100 *
                                100,
                            decoration: BoxDecoration(
                              color: KoalaColors.destructive,
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
                          style: KoalaTypography.caption(context).copyWith(
                              color: KoalaColors.textSecondary(context)),
                        ),
                        Text(
                          remaining >= 0
                              ? 'Reste: FCFA ${_formatAmount(remaining)}'
                              : 'Dépassement: FCFA ${_formatAmount(remaining.abs())}',
                          style: KoalaTypography.caption(context).copyWith(
                            fontWeight: remaining < 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: remaining < 0
                                ? KoalaColors.destructive
                                : KoalaColors.textSecondary(context),
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

  Widget _buildDebtTimelineCard(BuildContext context) {
    final debtTimeline = controller.debtTimeline;

    if (debtTimeline.isEmpty) {
      return _buildEmptyCard(
          context, 'Aucune donnée de dette pour cette période');
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
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xl),
        boxShadow: KoalaColors.shadowSubtle,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progression de la Dette',
            style: KoalaTypography.heading3(context),
          ),
          SizedBox(height: KoalaSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dette Totale Actuelle',
                style: KoalaTypography.bodyMedium(context)
                    .copyWith(color: KoalaColors.textSecondary(context)),
              ),
              Text(
                'FCFA ${_formatAmount(controller.debtTimeline.last.totalOutstanding)}',
                style: KoalaTypography.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: KoalaColors.destructive,
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
                style: KoalaTypography.bodyMedium(context)
                    .copyWith(color: KoalaColors.textSecondary(context)),
              ),
              Text(
                'FCFA ${_formatAmount(controller.debtTimeline.last.paymentsMade)}',
                style: KoalaTypography.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: KoalaColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: KoalaSpacing.lg),
          SizedBox(
            height: 200.h,
            child: RepaintBoundary(
              child: LineChart(
                LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return const Text('');
                          },
                          interval: (debtTimeline.length / 5)
                              .ceilToDouble()
                              .clamp(
                                  1.0,
                                  double
                                      .infinity), // Ensure interval is at least 1
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              // Use Padding instead of SideTitleWidget
                              padding: const EdgeInsets.only(
                                  right: 8.0), // Approximate spacing
                              child: Text(
                                NumberFormat.compact().format(value),
                                style: KoalaTypography.caption(context)
                                    .copyWith(fontSize: 10.sp),
                              ),
                            );
                          },
                          interval: ((maxY - minY) / 4).clamp(1.0,
                              double.infinity), // Ensure interval is at least 1
                          reservedSize: 40,
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                              Colors.redAccent.withValues(alpha: 0.3),
                              Colors.red.shade900.withValues(alpha: 0.1),
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
                    maxX: (debtTimeline.length - 1).toDouble()),
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
  void _showAddJobDialog(BuildContext context) {
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
                SizedBox(height: KoalaSpacing.lg),
                KoalaTextField(
                  controller: amountController,
                  label: 'Montant',
                  icon: CupertinoIcons.money_dollar,
                  keyboardType: TextInputType.number,
                  isAmount: true,
                ),
                SizedBox(height: KoalaSpacing.xxl),
                Text(
                  'Fréquence',
                  style: KoalaTypography.caption(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: KoalaColors.inputBackground(context),
                        borderRadius: BorderRadius.circular(KoalaRadius.sm),
                      ),
                      child: DropdownButton<PaymentFrequency>(
                        value: selectedFrequency.value,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: KoalaColors.surface(context),
                        items: PaymentFrequency.values
                            .map((freq) => DropdownMenuItem(
                                  value: freq,
                                  child: Text(freq.displayName,
                                      style:
                                          KoalaTypography.bodyMedium(context)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedFrequency.value = value;
                        },
                      ),
                    )),
                SizedBox(height: KoalaSpacing.xxxl),
                Row(
                  children: [
                    Expanded(
                      child: KoalaButton(
                        text: 'Annuler',
                        backgroundColor: KoalaColors.surface(context),
                        textColor: KoalaColors.textSecondary(context),
                        onPressed: () => NavigationHelper.safeBack(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: KoalaButton(
                        text: 'Ajouter',
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le nom du job est requis',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          if (amountController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le montant est requis',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            Get.snackbar('Erreur', 'Le montant doit être > 0',
                                snackPosition: SnackPosition.BOTTOM);
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
                SizedBox(height: KoalaSpacing.xxl), // Safe area padding
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showJobOptions(BuildContext context, Job job) {
    Get.bottomSheet(
      KoalaBottomSheet(
        title: job.name,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(CupertinoIcons.pencil,
                  color: KoalaColors.primaryUi(context)),
              title:
                  Text('Modifier', style: KoalaTypography.bodyMedium(context)),
              onTap: () {
                NavigationHelper.safeBack();
                _showEditJobDialog(context, job);
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.trash,
                  color: KoalaColors.destructive),
              title: Text('Supprimer',
                  style: KoalaTypography.bodyMedium(context)
                      .copyWith(color: KoalaColors.destructive)),
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
            SizedBox(height: KoalaSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showEditJobDialog(BuildContext context, Job job) {
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
                SizedBox(height: KoalaSpacing.lg),
                KoalaTextField(
                  controller: amountController,
                  label: 'Montant',
                  icon: CupertinoIcons.money_dollar,
                  keyboardType: TextInputType.number,
                  isAmount: true,
                ),
                SizedBox(height: KoalaSpacing.xxl),
                Text(
                  'Fréquence',
                  style: KoalaTypography.caption(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: KoalaColors.inputBackground(context),
                        borderRadius: BorderRadius.circular(KoalaRadius.sm),
                      ),
                      child: DropdownButton<PaymentFrequency>(
                        value: selectedFrequency.value,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: KoalaColors.surface(context),
                        items: PaymentFrequency.values
                            .map((freq) => DropdownMenuItem(
                                  value: freq,
                                  child: Text(freq.displayName,
                                      style:
                                          KoalaTypography.bodyMedium(context)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedFrequency.value = value;
                        },
                      ),
                    )),
                SizedBox(height: KoalaSpacing.xxxl),
                Row(
                  children: [
                    Expanded(
                      child: KoalaButton(
                        text: 'Annuler',
                        backgroundColor: KoalaColors.surface(context),
                        textColor: KoalaColors.textSecondary(context),
                        onPressed: () => NavigationHelper.safeBack(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: KoalaButton(
                        text: 'Enregistrer',
                        backgroundColor: KoalaColors.primaryUi(context),
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le nom du job est requis',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          if (amountController.text.trim().isEmpty) {
                            Get.snackbar('Erreur', 'Le montant est requis',
                                snackPosition: SnackPosition.BOTTOM);
                            return;
                          }
                          final amount = double.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            Get.snackbar('Erreur', 'Le montant doit être > 0',
                                snackPosition: SnackPosition.BOTTOM);
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
                SizedBox(height: KoalaSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
