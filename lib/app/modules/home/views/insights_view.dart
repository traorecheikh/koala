import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koaa/app/core/design_system.dart';
import 'package:koaa/app/modules/home/controllers/home_controller.dart';
import 'package:koaa/app/services/ml/models/insight_generator.dart';
import 'package:koaa/app/routes/app_pages.dart';

class InsightsView extends GetView<HomeController> {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KoalaColors.background(context),
      appBar: AppBar(
        title: Text('Intelligence', style: KoalaTypography.heading3(context)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: KoalaColors.text(context)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Filter expired insights here or rely on Controller?
        // Let's filter here for display safety (72h)
        final now = DateTime.now();
        final validInsights = controller.insights.where((i) {
          final age = now.difference(i.createdAt);
          return age.inHours < 72;
        }).toList();

        // Sort by priority (high to low) and then by date (newest first)
        validInsights.sort((a, b) {
          final priorityComp = b.priority.compareTo(a.priority);
          if (priorityComp != 0) return priorityComp;
          return b.createdAt.compareTo(a.createdAt);
        });

        if (validInsights.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.lightbulb_slash,
                  size: 64.sp,
                  color: KoalaColors.textSecondary(context).withOpacity(0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Aucun insight pour le moment',
                  style: KoalaTypography.bodyLarge(context).copyWith(
                    color: KoalaColors.textSecondary(context),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Revenez plus tard !',
                  style: KoalaTypography.caption(context),
                ),
              ],
            ).animate().fadeIn(),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: validInsights.length,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            final insight = validInsights[index];
            return _InsightDetailCard(insight: insight);
          },
        );
      }),
    );
  }
}

class _InsightDetailCard extends StatelessWidget {
  final MLInsight insight;

  const _InsightDetailCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (insight.type) {
      case InsightType.positive:
        color = KoalaColors.success;
        icon = CupertinoIcons.checkmark_circle_fill;
        break;
      case InsightType.warning:
        color = KoalaColors.warning;
        icon = CupertinoIcons.exclamationmark_triangle_fill;
        break;
      case InsightType.tip:
        color = KoalaColors.accent;
        icon = CupertinoIcons.info_circle_fill;
        break;
      case InsightType.info:
        color = KoalaColors.textSecondary(context);
        icon = CupertinoIcons.lightbulb_fill;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: KoalaColors.surface(context),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: KoalaColors.shadowMedium,
        border: Border.all(color: KoalaColors.border(context)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show full details dialog or sheet
            _showDetailSheet(context, insight, color, icon);
          },
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: KoalaTypography.heading4(context),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _getTimeAgo(insight.createdAt),
                            style: KoalaTypography.caption(context).copyWith(
                                color: KoalaColors.textSecondary(context)),
                          ),
                        ],
                      ),
                    ),
                    if (insight.priority >= 9)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: KoalaColors.destructive,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text('URGENT',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  insight.description,
                  style:
                      KoalaTypography.bodyMedium(context).copyWith(height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Voir détails',
                        style: TextStyle(
                            color: KoalaColors.primary,
                            fontWeight: FontWeight.w600)),
                    Icon(CupertinoIcons.chevron_right,
                        color: KoalaColors.primary, size: 16.sp),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  void _showDetailSheet(
      BuildContext context, MLInsight insight, Color color, IconData icon) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: KoalaColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
              margin: EdgeInsets.only(bottom: 24.h),
            ),
            Icon(icon, size: 48.sp, color: color),
            SizedBox(height: 16.h),
            Text(insight.title,
                style: KoalaTypography.heading3(context),
                textAlign: TextAlign.center),
            SizedBox(height: 24.h),
            Text(insight.description,
                style: KoalaTypography.bodyLarge(context),
                textAlign: TextAlign.center),
            SizedBox(height: 32.h),
            // Stats placeholder
            if (insight.relatedData != null)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: KoalaColors.background(context),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: insight.relatedData!.entries
                      .map((e) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key,
                                    style: KoalaTypography.caption(context)),
                                Text(e.value.toString(),
                                    style: KoalaTypography.bodyMedium(context)
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            SizedBox(height: 32.h),
            if (insight.actionLabel != null)
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: color,
                  borderRadius: BorderRadius.circular(16.r),
                  onPressed: () {
                    Get.back();
                    _handleAction(insight);
                  },
                  child: Text(insight.actionLabel!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _handleAction(MLInsight insight) {
    final label = insight.actionLabel?.toLowerCase() ?? '';
    if (label.contains('budget') || label.contains('dépenses')) {
      Get.toNamed(Routes.budget);
    } else if (label.contains('dette') || label.contains('remboursement')) {
      Get.toNamed(Routes.debt);
    } else if (label.contains('objectif')) {
      Get.toNamed(Routes.goals);
    } else {
      Get.toNamed(Routes.analytics);
    }
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return 'À l\'instant';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}j';
  }
}
