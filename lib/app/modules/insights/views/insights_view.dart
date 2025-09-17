import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/insights/controllers/insights_controller.dart';

/// Modern insights view with AI-powered financial analysis
/// - Smart spending insights
/// - Category breakdown
/// - Trends analysis
/// - Personalized recommendations
class InsightsView extends GetView<InsightsController> {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Analyses IA',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showTimeframePicker(context),
              icon: const Icon(Icons.date_range_rounded),
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Aperçu'),
              Tab(text: 'Catégories'),
              Tab(text: 'Tendances'),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildCategoriesTab(context),
            _buildTrendsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildFinancialOverview(context)),
          SizedBox(height: 24.h),
          // FadeInUp(
          //   delay: const Duration(milliseconds: 200),
          //   child: _buildInsightsList(context),
          // ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aperçu Financier',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),

          // Budget usage
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget utilisé',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(
                      () => Text(
                        '${controller.totalSpent.value.toStringAsFixed(0)} / ${controller.budgetLimit.value.toStringAsFixed(0)} XOF',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => CircularProgressIndicator(
                  value: controller.budgetUsagePercentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    controller.budgetUsagePercentage > 0.8
                        ? Colors.red.shade300
                        : Colors.white,
                  ),
                  strokeWidth: 6.w,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: Colors.white.withOpacity(0.3)),
          SizedBox(height: 16.h),

          // Savings progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objectif d\'épargne',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Obx(
                      () => Text(
                        '${controller.currentSavings.value.toStringAsFixed(0)} / ${controller.savingsGoal.value.toStringAsFixed(0)} XOF',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Text(
                  '${(controller.savingsPercentage * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildInsightsList(BuildContext context) {
  //   final theme = Theme.of(context);
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Recommandations IA',
  //         style: theme.textTheme.titleLarge?.copyWith(
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       SizedBox(height: 16.h),
  //       Obx(() {
  //         if (controller.insights.isEmpty) {
  //           return _buildNoInsightsState(context);
  //         }
  //         return ListView.separated(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: controller.insights.length,
  //           separatorBuilder: (context, index) => SizedBox(height: 12.h),
  //           itemBuilder: (context, index) {
  //             final insight = controller.insights[index];
  //             return FadeInUp(
  //               delay: Duration(milliseconds: index * 100),
  //               child: _buildInsightCard(context, insight),
  //             );
  //           },
  //         );
  //       }),
  //     ],
  //   );
  // }

  /// Clean, professional insight card design inspired by modern financial apps
  Widget _buildInsightCard(BuildContext context, Map<String, dynamic> insight) {
    final theme = Theme.of(context);
    final type = insight['type'] as String;
    final title = insight['title'] as String;
    final description = insight['description'] as String;
    final amount = insight['amount'] as double;
    final icon = insight['icon'] as IconData;
    final priority = insight['priority'] as String;
    final suggestions = insight['suggestions'] as List<String>? ?? [];

    // Clean, minimal color coding (like Revolut/Monzo)
    Color getAccentColor() {
      switch (type) {
        case 'warning':
          return const Color(0xFFFF6B6B); // Soft red
        case 'success':
          return const Color(0xFF51CF66); // Soft green  
        case 'info':
          return theme.colorScheme.primary;
        default:
          return theme.colorScheme.onSurfaceVariant;
      }
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            children: [
              // Clean icon container (Airbnb style)
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: getAccentColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: getAccentColor(),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (amount > 0) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '${amount.toStringAsFixed(0)} XOF',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: getAccentColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Clean priority badge
              if (priority == 'high')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: getAccentColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Important',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: getAccentColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Description with proper spacing
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          
          // Clean suggestions section (if available)
          if (suggestions.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggestions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...suggestions.take(3).map((suggestion) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4.w,
                          height: 4.w,
                          margin: EdgeInsets.only(top: 8.h, right: 10.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoInsightsState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.psychology_outlined,
              size: 28.sp,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Aucune analyse disponible',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ajoutez plus de transactions pour obtenir des recommandations personnalisées',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildSpendingChart(context)),
          SizedBox(height: 24.h),
          Text(
            'Répartition par catégorie',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildCategoryList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChart(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Dépenses par catégorie',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          // Placeholder for chart - in real app you'd use a chart library
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 48.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Graphique interactif',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Bientôt disponible',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return Obx(() {
      if (controller.categorySpending.isEmpty) {
        return _buildNoCategoriesState(context);
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.categorySpending.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final category = controller.categorySpending[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 100),
            child: _buildCategoryCard(context, category),
          );
        },
      );
    });
  }

  Widget _buildNoCategoriesState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 12.h),
          Text(
            'Aucune donnée de catégorie',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final theme = Theme.of(context);
    final amount = category['amount'] as double;
    final percentage = category['percentage'] as double;
    final trend = category['trend'] as String;
    final previousAmount = category['previousAmount'] as double;
    final change = amount - previousAmount;

    Color getTrendColor() {
      switch (trend) {
        case 'up':
          return theme.colorScheme.error;
        case 'down':
          return theme.colorScheme.primary;
        case 'stable':
          return theme.colorScheme.onSurfaceVariant;
        default:
          return theme.colorScheme.onSurfaceVariant;
      }
    }

    IconData getTrendIcon() {
      switch (trend) {
        case 'up':
          return Icons.trending_up_rounded;
        case 'down':
          return Icons.trending_down_rounded;
        case 'stable':
          return Icons.trending_flat_rounded;
        default:
          return Icons.trending_flat_rounded;
      }
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              category['icon'] as IconData,
              color: theme.colorScheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['category'] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${(percentage * 100).toStringAsFixed(1)}% du total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${amount.toStringAsFixed(0)} XOF',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (change != 0) ...[
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(getTrendIcon(), size: 16.sp, color: getTrendColor()),
                    SizedBox(width: 4.w),
                    Text(
                      '${change > 0 ? '+' : ''}${change.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: getTrendColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildTrendsChart(context)),
          SizedBox(height: 24.h),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildTrendsSummary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsChart(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Tendances des dépenses',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    size: 48.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Graphique linéaire',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Bientôt disponible',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSummary(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyse des tendances',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildTrendItem(
                context,
                'Dépense moyenne quotidienne',
                '25,714 XOF',
                Icons.calendar_today_rounded,
                theme.colorScheme.primary,
              ),
              SizedBox(height: 12.h),
              _buildTrendItem(
                context,
                'Jour le plus dépensier',
                'Samedi (45,000 XOF)',
                Icons.trending_up_rounded,
                theme.colorScheme.error,
              ),
              SizedBox(height: 12.h),
              _buildTrendItem(
                context,
                'Économie cette semaine',
                '-3,000 XOF vs semaine précédente',
                Icons.trending_down_rounded,
                theme.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTimeframePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Période d\'analyse',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            ...['Cette semaine', 'Ce mois', 'Cette année'].map((timeframe) {
              return Obx(
                () => RadioListTile<String>(
                  title: Text(timeframe),
                  value: timeframe,
                  groupValue: controller.selectedTimeframe.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeTimeframe(value);
                      Get.back();
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
