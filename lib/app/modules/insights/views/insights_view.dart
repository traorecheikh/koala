import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koala/app/modules/insights/controllers/insights_controller.dart';

class InsightsView extends GetView<InsightsController> {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Insights'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Categories'),
              Tab(text: 'Trends'),
              Tab(text: 'Tips'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildCategoriesTab(context),
            _buildTrendsTab(context),
            _buildTipsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return Obx(() {
      if (controller.insights.isEmpty) {
        return const Center(child: Text('No insights available.'));
      }
      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.insights.length,
        itemBuilder: (context, index) {
          final insight = controller.insights[index];
          return _buildInsightCard(context, insight);
        },
      );
    });
  }

  Widget _buildCategoriesTab(BuildContext context) {
    return Column(
      children: [
        _buildChartPlaceholder(context, 'Category Spending'),
        Expanded(
          child: Obx(() {
            if (controller.categorySpending.isEmpty) {
              return const Center(child: Text('No category data available.'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.categorySpending.length,
              itemBuilder: (context, index) {
                final category = controller.categorySpending[index];
                return _buildCategoryCard(context, category);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTrendsTab(BuildContext context) {
    return Column(
      children: [
        _buildChartPlaceholder(context, 'Spending Trends'),
        // Additional trend analysis can be added here
      ],
    );
  }

  Widget _buildTipsTab(BuildContext context) {
    // For simplicity, we'll reuse the insights as tips for now.
    return _buildOverviewTab(context);
  }

  Widget _buildInsightCard(BuildContext context, Map<String, dynamic> insight) {
    final theme = Theme.of(context);
    final color = _getColorFromType(theme, insight['type'] as String);
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(insight['icon'] as IconData, color: color),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(insight['title'] as String, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(insight['description'] as String, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(category['icon'] as IconData, color: theme.colorScheme.primary),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(category['category'] as String, style: theme.textTheme.titleMedium),
            ),
            Text('${category['amount']} XOF', style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          SizedBox(height: 16.h),
          const Center(
            child: Icon(Icons.bar_chart, size: 50, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          const Text('Chart will be implemented here.'),
        ],
      ),
    );
  }

  Color _getColorFromType(ThemeData theme, String type) {
    switch (type) {
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'info':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }
}