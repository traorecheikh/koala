// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/services/ml/smart_financial_brain.dart';
import 'package:koaa/app/data/models/ml/financial_intelligence.dart';
import 'package:koaa/app/services/intelligence/intelligence_service.dart';
import 'package:koaa/app/core/utils/navigation_helper.dart';
import 'package:koaa/app/routes/app_pages.dart';
import 'package:koaa/app/modules/settings/controllers/categories_controller.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';

class IntelligenceView extends StatelessWidget {
  const IntelligenceView({super.key});

  String _getCategoryName(String categoryId) {
    try {
      final controller = Get.find<CategoriesController>();
      final category =
          controller.categories.firstWhereOrNull((c) => c.id == categoryId);
      return category?.name ?? 'Autre';
    } catch (e) {
      return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SmartFinancialBrain>()) {
      Get.put(SmartFinancialBrain());
    }

    final brain = Get.find<SmartFinancialBrain>();

    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
          onPressed: () => NavigationHelper.safeBack(),
        ),
        title: Text(
          'Intelligence IA',
          style: KoalaTypography.heading3(context),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            // Determine if there are active insights using HomeController
            // Note: requires finding HomeController in view or passing it
            if (!Get.isRegistered<HomeController>()) {
              return const SizedBox.shrink();
            }
            final homeCtrl = Get.find<HomeController>();
            final hasInsights = homeCtrl.insights.isNotEmpty;

            return Stack(
              children: [
                IconButton(
                  icon: Icon(CupertinoIcons.lightbulb_fill,
                      color: KoalaColors.text(context)),
                  onPressed: () =>
                      Get.toNamed(Routes.insights), // Correct route
                  tooltip: 'Insights',
                ),
                if (hasInsights)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: KoalaColors.destructive,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          })
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final intel = brain.intelligence.value;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ═══════════════════════════════════════════════════════════
                // FINANCIAL HEALTH SCORE
                // ═══════════════════════════════════════════════════════════
                _buildHealthScore(context, intel),

                SizedBox(height: 24.h), // Standardized spacing

                // ═══════════════════════════════════════════════════════════
                // CASH FLOW
                // ═══════════════════════════════════════════════════════════
                _buildSectionTitle(
                    context, 'Trésorerie', CupertinoIcons.money_dollar_circle),
                SizedBox(height: 12.h),
                _buildCashFlowCard(context, intel.cashFlowPrediction),

                SizedBox(height: 24.h),

                // ═══════════════════════════════════════════════════════════
                // SPENDING BEHAVIOR
                // ═══════════════════════════════════════════════════════════
                _buildSectionTitle(
                    context, 'Comportement', CupertinoIcons.chart_bar),
                SizedBox(height: 12.h),
                _buildSpendingCard(context, intel.spendingBehavior),

                // Top Categories
                if (intel.spendingBehavior.categoryBreakdown.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildCategoryList(
                      context, intel.spendingBehavior.categoryBreakdown),
                ],

                SizedBox(height: 24.h),

                // ═══════════════════════════════════════════════════════════
                // QUICK STATS
                // ═══════════════════════════════════════════════════════════
                _buildQuickStatsGrid(context, intel),

                SizedBox(height: 24.h),

                // ═══════════════════════════════════════════════════════════
                // RECOMMENDATIONS
                // ═══════════════════════════════════════════════════════════
                if (intel.recommendations.isNotEmpty) ...[
                  _buildSectionTitle(
                      context, 'Conseils IA', CupertinoIcons.lightbulb),
                  SizedBox(height: 12.h),
                  ...intel.recommendations
                      .take(5)
                      .map((r) => _buildRecommendation(context, r)),
                ],

                SizedBox(height: 40.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: KoalaColors.textSecondary(context)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: KoalaTypography.heading4(context).copyWith(
            color: KoalaColors.textSecondary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildHealthScore(BuildContext context, FinancialIntelligence intel) {
    // Get the ACTUAL health score from IntelligenceService for consistency with dashboard
    final intelligenceService = Get.find<IntelligenceService>();
    final score = intelligenceService.getSummary().healthScore;

    Color color;
    String label;
    IconData icon;

    // Determine display based on actual score (same logic as dashboard)
    if (score >= 80) {
      color = KoalaColors.success;
      label = 'Excellent';
      icon = CupertinoIcons.checkmark_shield_fill;
    } else if (score >= 60) {
      color = KoalaColors.success.withValues(alpha: 0.8);
      label = 'Bon';
      icon = CupertinoIcons.checkmark_circle_fill;
    } else if (score >= 40) {
      color = KoalaColors.warning;
      label = 'Modéré';
      icon = CupertinoIcons.exclamationmark_circle_fill;
    } else if (score >= 20) {
      color = KoalaColors.warning;
      label = 'Attention';
      icon = CupertinoIcons.exclamationmark_triangle_fill;
    } else {
      color = KoalaColors.destructive;
      label = 'Critique';
      icon = CupertinoIcons.xmark_circle_fill;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(
            KoalaRadius.lg), // Standard 20.r for big cards
        boxShadow: KoalaShadows.md,
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 36.sp),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Santé Financière',
                    style: KoalaTypography.bodySmall(context)),
                SizedBox(height: 4.h),
                Text(label,
                    style: KoalaTypography.heading2(context)
                        .copyWith(color: color)),
                SizedBox(height: 6.h),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: KoalaColors.border(context),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6.h,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Text('$score',
              style: KoalaTypography.heading1(context).copyWith(color: color)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildCashFlowCard(BuildContext context, CashFlowPrediction pred) {
    // Determine status color using semantics
    final isHealthy =
        pred.willSurviveMonth && pred.predictedMonthEndBalance > 0;
    final color = isHealthy ? KoalaColors.success : KoalaColors.destructive;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.md),
        boxShadow: KoalaShadows.sm,
      ),
      child: Column(
        children: [
          // Balance row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solde actuel',
                        style: KoalaTypography.caption(context)),
                    Text(_fmt(pred.currentBalance),
                        style: KoalaTypography.heading4(context)),
                  ],
                ),
              ),
              Icon(CupertinoIcons.arrow_right,
                  color: KoalaColors.textSecondary(context), size: 16.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Fin de mois',
                        style: KoalaTypography.caption(context)),
                    Text(_fmt(pred.predictedMonthEndBalance),
                        style: KoalaTypography.heading4(context)
                            .copyWith(color: color)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Metrics
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: KoalaColors.background(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                    context, 'Dépense/j', _fmtShort(pred.avgDailySpending)),
                _buildMetric(
                    context, 'Budget/j', _fmtShort(pred.safeDailySpending)),
                _buildMetric(context, 'Jours', '${pred.daysRemainingInMonth}'),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, delay: 100.ms);
  }

  Widget _buildMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value,
            style: KoalaTypography.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: KoalaTypography.caption(context)),
      ],
    );
  }

  Widget _buildSpendingCard(BuildContext context, SpendingBehavior behavior) {
    Color color;
    String label;

    switch (behavior.pattern) {
      case SpendingPattern.reckless:
        color = KoalaColors.destructive;
        label = 'Dépenses excessives';
        break;
      case SpendingPattern.aggressive:
        color = KoalaColors.warning;
        label = 'Dépenses agressives';
        break;
      case SpendingPattern.atRisk:
        color = KoalaColors.warning.withValues(alpha: 0.8);
        label = 'À surveiller';
        break;
      case SpendingPattern.balanced:
        color = KoalaColors.success;
        label = 'Équilibré';
        break;
      case SpendingPattern.conservative:
        color = KoalaColors.success;
        label = 'Économe';
        break;
    }

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.analytics),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          boxShadow: KoalaShadows.sm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(KoalaRadius.sm)),
                  child: Icon(CupertinoIcons.flame, color: color, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: KoalaTypography.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.bold, color: color)),
                      Text(
                          'Vélocité: ${(behavior.velocityRatio * 100).toStringAsFixed(0)}%',
                          style: KoalaTypography.caption(context)),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right,
                    color: KoalaColors.textSecondary(context), size: 16.sp),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                    child: _buildStatTile(context, 'Ce mois',
                        _fmtShort(behavior.totalSpentThisMonth))),
                SizedBox(width: 8.w),
                Expanded(
                    child: _buildStatTile(context, 'Moy/jour',
                        _fmtShort(behavior.avgDailySpending))),
                SizedBox(width: 8.w),
                Expanded(
                    child: _buildStatTile(context, 'Projection',
                        _fmtShort(behavior.projectedMonthEndSpending))),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, delay: 150.ms);
  }

  Widget _buildStatTile(BuildContext context, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: KoalaColors.background(context),
        borderRadius: BorderRadius.circular(KoalaRadius.xs),
      ),
      child: Column(
        children: [
          Text(value,
              style: KoalaTypography.bodySmall(context)
                  .copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 2.h),
          Text(label,
              style: KoalaTypography.caption(context).copyWith(fontSize: 10.sp),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context, Map<String, double> categories) {
    final sorted = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = categories.values.fold(0.0, (a, b) => a + b);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(KoalaRadius.md),
        boxShadow: KoalaShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Catégories', style: KoalaTypography.heading4(context)),
          SizedBox(height: 12.h),
          ...sorted.take(4).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final cat = entry.value;
            final percent = total > 0 ? (cat.value / total * 100) : 0;
            final colors = [
              KoalaColors.accent,
              Colors.purple,
              KoalaColors.warning,
              Colors.pink
            ];
            final color = colors[index % colors.length];
            final categoryName = _getCategoryName(cat.key);

            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(categoryName,
                        style: KoalaTypography.bodyMedium(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 8.w),
                  Text('${percent.toStringAsFixed(0)}%',
                      style: KoalaTypography.bodySmall(context)
                          .copyWith(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, delay: 200.ms);
  }

  Widget _buildQuickStatsGrid(
      BuildContext context, FinancialIntelligence intel) {
    return Row(
      children: [
        Expanded(
            child: _buildQuickStatCard(
                context,
                'Budgets',
                '${intel.budgetHealth.overallHealth}%',
                CupertinoIcons.chart_pie,
                intel.budgetHealth.overallHealth >= 70
                    ? KoalaColors.success
                    : KoalaColors.warning,
                Routes.budget)),
        SizedBox(width: 10.w),
        Expanded(
            child: _buildQuickStatCard(
                context,
                'Objectifs',
                '${intel.goalProgress.activeGoalCount}',
                CupertinoIcons.flag,
                KoalaColors.accent,
                Routes.goals)),
        SizedBox(width: 10.w),
        Expanded(
            child: _buildQuickStatCard(
                context,
                'Dettes',
                '${intel.debtStrategy.activeDebtCount}',
                CupertinoIcons.money_dollar,
                intel.debtStrategy.activeDebtCount > 0
                    ? KoalaColors.destructive
                    : KoalaColors.success,
                Routes.debt)),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, delay: 250.ms);
  }

  Widget _buildQuickStatCard(BuildContext context, String label, String value,
      IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(route);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          boxShadow: KoalaShadows.sm,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(height: 8.h),
            Text(value, style: KoalaTypography.heading4(context)),
            Text(label, style: KoalaTypography.caption(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, SmartRecommendation rec) {
    Color color;
    IconData icon;

    switch (rec.priority) {
      case RecommendationPriority.critical:
        color = KoalaColors.destructive;
        icon = CupertinoIcons.xmark_octagon;
        break;
      case RecommendationPriority.high:
        color = KoalaColors.warning;
        icon = CupertinoIcons.exclamationmark_triangle;
        break;
      case RecommendationPriority.medium:
        color = KoalaColors.warning;
        icon = CupertinoIcons.lightbulb;
        break;
      default:
        color = KoalaColors.success;
        icon = CupertinoIcons.checkmark_alt;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(rec.actionRoute);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.circular(KoalaRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(KoalaRadius.xs)),
              child: Icon(icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.title,
                      style: KoalaTypography.bodyMedium(context)
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h),
                  Text(rec.description,
                      style: KoalaTypography.caption(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(CupertinoIcons.chevron_right,
                color: KoalaColors.textSecondary(context), size: 14.sp),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
  }

  // Formatting helpers
  String _fmt(double amount) =>
      '${NumberFormat('#,###', 'fr_FR').format(amount.round())} F';
  String _fmtShort(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return '${amount.round()}';
  }
}
